GeoNames data bundled for offline reverse geocoding (no network):

- cities15000.txt — cities with population ≥ 15,000 (coordinates + admin1/admin2 codes).
- admin1CodesASCII.txt — English names for first-level admin divisions (state/province).
- admin2Codes.txt — English names for second-level divisions (e.g. US counties; format varies by country).

Implementation uses package:kdtree for nearest-city search and resolves names via
`country.admin1` and `country.admin1.admin2` keys.

License: Creative Commons Attribution 4.0 — https://www.geonames.org/

Upstream:
- https://download.geonames.org/export/dump/cities15000.zip
- https://download.geonames.org/export/dump/admin1CodesASCII.txt
- https://download.geonames.org/export/dump/admin2Codes.txt

Maintainer notes (attribution, where to disclose in the app): docs/offline_geodata_geonames.md
