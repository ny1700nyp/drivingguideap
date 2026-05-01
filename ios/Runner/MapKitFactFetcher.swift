import Foundation
import MapKit

enum MapKitFactFetcher {
  static func fetchFacts(
    regionName: String,
    latitude: Double?,
    longitude: Double?
  ) async -> [String: [String]] {
    async let scenic = search(
      query: "scenic viewpoint near \(regionName)",
      latitude: latitude,
      longitude: longitude
    )
    async let landmarks = search(
      query: "landmarks near \(regionName)",
      latitude: latitude,
      longitude: longitude
    )

    let scenicResults = await scenic
    let landmarkResults = await landmarks

    return [
      "canvas": Array(scenicResults.prefix(4)),
      "icons": Array(landmarkResults.prefix(4)),
    ]
  }

  private static func search(
    query: String,
    latitude: Double?,
    longitude: Double?
  ) async -> [String] {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.resultTypes = [.pointOfInterest]

    if let latitude = latitude, let longitude = longitude {
      request.region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
        latitudinalMeters: 15_000,
        longitudinalMeters: 15_000
      )
    }

    return await withCheckedContinuation { continuation in
      MKLocalSearch(request: request).start { response, _ in
        let results = response?.mapItems.prefix(3).compactMap { item -> String? in
          guard let name = item.name, !name.isEmpty else {
            return nil
          }
          if let locality = item.placemark.locality, !locality.isEmpty {
            return "\(name) in \(locality)"
          }
          return name
        } ?? []
        continuation.resume(returning: Array(results))
      }
    }
  }
}
