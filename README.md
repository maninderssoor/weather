# Weather

[![iOS Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](https://img.shields.io/badge/platform-ios-lightgrey.svg)

## Requirments

Use the OpenWeather API endpoint http://openweathermap.org/forecast5 to retrieve data for displaying a 5 days forecast with 3- hour steps, for a specific city selected by the user.

Present data in visual layout, where every day represents a row, and every 3-hour weather forecast represents a cell in a row. The user must be able to scroll the cells within the row.

Each row should clearly show date, and each cell within the row should clearly show the temperature and the time of the day. Present city/town/postcode as well, whichever applicable.

## Notes

Weather's been built using MVVM architecture, UIKit for View Controllers/ Views & Combine for networking. 

Weather forecasts are fetched in the view model using `Forecast` decodable type. The view updates using delegate call backs from the view model.

UI: 
- `UICollectionViewDiffableDataSource` and `UICollectionViewCompositionalLayout` have been used, so we can implement varying scroll directions, if they're needed at a later stage.
- Each row represents a day of the week, with 3 hourly forecasts and weather iconography displayed for that day.
- To get weather for your GPS location, tap the navigation arrow in the top right of the navigation pane.
- Once you've searched for a location, tap on the pin mark icon (right of the Search bar) to view this location on a map.

Unit and UI tests have been added.

## Author

Maninder Soor (http://manindersoor.com)
