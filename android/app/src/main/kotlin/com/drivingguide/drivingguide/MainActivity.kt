package com.drivingguide.drivingguide

import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerativeModel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val channelName = "drivingguide/local_llm"
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var androidLLMService: AndroidLocalLLMService? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        androidLLMService = AndroidLocalLLMService()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            val service = androidLLMService ?: AndroidLocalLLMService().also {
                androidLLMService = it
            }

            when (call.method) {
                "getModelInfo" -> scope.launch {
                    result.success(service.modelInfo())
                }

                "loadModel" -> scope.launch {
                    service.loadModel()
                    result.success(null)
                }

                "generateText" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt == null) {
                        result.error("bad_arguments", "generateText requires a prompt string.", null)
                        return@setMethodCallHandler
                    }

                    scope.launch {
                        result.success(service.generateText(prompt))
                    }
                }

                "enterStandby" -> scope.launch {
                    service.enterStandby()
                    result.success(null)
                }

                "unloadModel" -> scope.launch {
                    service.unloadModel()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        androidLLMService?.unloadModel()
        scope.cancel()
        super.onDestroy()
    }
}

private class AndroidLocalLLMService {
    private var generativeModel: GenerativeModel? = null

    suspend fun modelInfo(): Map<String, Any> {
        val model = model()
        val status = runCatching { model.checkStatus() }.getOrNull()
        val availability = statusLabel(status)
        val modelName = if (status == FeatureStatus.AVAILABLE) {
            runCatching { model.getBaseModelName() }.getOrDefault("Gemini Nano")
        } else {
            "Gemini Nano"
        }

        return mapOf(
            "provider" to "Android ML Kit GenAI Prompt API",
            "modelName" to modelName,
            "availability" to availability,
            "usesFallback" to (status != FeatureStatus.AVAILABLE),
        )
    }

    suspend fun loadModel(): Boolean {
        if (!ensureAvailable(downloadIfNeeded = true)) {
            return false
        }
        return runCatching {
            model().warmup()
            true
        }.getOrDefault(false)
    }

    suspend fun generateText(prompt: String): String? {
        if (!ensureAvailable(downloadIfNeeded = true)) {
            return null
        }

        return runCatching {
            val response = model().generateContent(prompt)
            response.candidates.firstOrNull()?.text?.trim()?.takeIf { it.isNotEmpty() }
        }.getOrNull()
    }

    suspend fun enterStandby() {
        runCatching { generativeModel?.clearImplicitCaches() }
    }

    fun unloadModel() {
        generativeModel?.close()
        generativeModel = null
    }

    private fun model(): GenerativeModel {
        val existingModel = generativeModel
        if (existingModel != null) {
            return existingModel
        }

        return Generation.getClient().also {
            generativeModel = it
        }
    }

    private suspend fun ensureAvailable(downloadIfNeeded: Boolean): Boolean {
        val model = model()
        return when (runCatching { model.checkStatus() }.getOrNull()) {
            FeatureStatus.AVAILABLE -> true
            FeatureStatus.DOWNLOADABLE -> {
                if (!downloadIfNeeded) {
                    false
                } else {
                    downloadModel(model) && model.checkStatus() == FeatureStatus.AVAILABLE
                }
            }
            else -> false
        }
    }

    private suspend fun downloadModel(model: GenerativeModel): Boolean {
        var downloaded = false
        runCatching {
            model.download().collect { status ->
                if (status == DownloadStatus.DownloadCompleted) {
                    downloaded = true
                }
            }
        }
        return downloaded
    }

    private fun statusLabel(status: Int?): String {
        return when (status) {
            FeatureStatus.AVAILABLE -> "AVAILABLE"
            FeatureStatus.DOWNLOADABLE -> "DOWNLOADABLE"
            FeatureStatus.DOWNLOADING -> "DOWNLOADING"
            FeatureStatus.UNAVAILABLE -> "UNAVAILABLE"
            null -> "UNKNOWN"
            else -> "UNKNOWN($status)"
        }
    }
}
