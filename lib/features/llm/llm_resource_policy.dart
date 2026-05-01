class LlmResourcePolicy {
  const LlmResourcePolicy();

  bool shouldGenerate({required double speedMph, required bool regionChanged}) {
    return regionChanged;
  }

  bool shouldStandbyAfterGeneration() => true;
}
