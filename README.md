# Commercial Time Tracking App for Mac

## Naming App Store
- Whazzup (original fork) 300duizend
- Wazzup (original fork) 2miljoen
- Wassup (more hits) 11miljoen
- Whassup (more hits) 600duizend

## A passive time tracker
Whazzup is a OS X application which asks on a regular (but slightly
random) schedule what you're doing. Used for time-tracking, and a subtle
nag to get back to useful work.

## TODO
- [x] Preference: ask-interval
- [x] Preference: take picture, yes/no
- [x] report: markdown
- [x] merge refactoring from fork whazzup

- [ ] reporting
  - [ ] Database storage
    - [ ] test cdq
    - [ ] migration
    - [ ] wrting
    - [ ] reading
  - [ ] report: csv export
  - [ ] report: aggregate periods
- [ ] setting: click on icon for ask
- [ ] Menu bar icon, light up whan asking
- [ ] Move to menu bar

- [ ] markdown use ljust to beautify table
- [ ] pdf export



- [ ] Shortcut to enter the same activity as last entry

- [ ] Glopal shortcut https://github.com/Clipy/Magnet

- [ ] Smart auto focus system


- [ ] report: monthly pictures

- [ ] schedule: disable in the weekend

- [ ] disable function: for an x period
- [ ] disable function: untill a moment
- [ ] disable function: at the first workday



## In de app store

- maak een bundle id aan in de developer-omgeving
- maak ook een bundle id aan in itunes connect
- gebruik dezelfde bundle id in Rakefile

### Maak archief
```
rake archive:distribution
```

#### Fout certicaat
➜  wassup git:(master) rake archive:distribution
     Build ./build/MacOSX-10.9-Release
  Codesign ./build/MacOSX-10.9-Release/WassUp.app
    ERROR! Cannot find any Mac Distribution certificate in the keychain.

- Zorg dat er geen dubbele certificaten zijn
- gebruik alleen certificaat

### Gebruik motion-appstore

```
motion validate pim@lingewoud.nl

✗ Error: Unable to validate archive '././build/MacOSX-10.9-Release/WassUp.pkg': (
✗ Unable to process validateProductSoftwareAttributes request at this time due to a general error.

```

### Missing required icons 

```
✗ Missing required icons. The application bundle does not contain an icon in ICNS format, containing both a 512x512 and a 512x512@2x image. For further assistance, see the Apple Human Interface Guidelines.
```
- maak een folder met een iconset
- gebruik icontool om een icns bestand te maken
- gebruik geen json file maar naamconventies

```
drwxr-xr-x+ 13 pim  staff      442  6 apr 17:17 AppIcon.iconset
  -rw-r--r--@  1 pim  staff   25061  6 apr 17:15 icon_128x128.png
  -rw-r--r--@  1 pim  staff   73433  6 apr 17:16 icon_128x128@2x.png
  -rw-r--r--@  1 pim  staff    1198  6 apr 17:15 icon_16x16.png
  -rw-r--r--@  1 pim  staff    2885  6 apr 17:15 icon_16x16@2x.png
  -rw-r--r--@  1 pim  staff   73433  6 apr 17:16 icon_256x256.png
  -rw-r--r--@  1 pim  staff  208157  6 apr 17:16 icon_256x256@2x.png
  -rw-r--r--@  1 pim  staff    2885  6 apr 17:15 icon_32x32.png
  -rw-r--r--@  1 pim  staff    8218  6 apr 17:15 icon_32x32@2x.png
  -rw-r--r--@  1 pim  staff  208157  6 apr 17:16 icon_512x512.png
  -rw-r--r--@  1 pim  staff  607235  6 apr 17:16 icon_512x512@2x.png
```
- iconutil -c icns AppIcon.iconset

### Entitlements

✗ App sandbox not enabled. The following executables must include the \"com.apple.security.app-sandbox\" entitlement with a Boolean value of true in the entitlements property list: [( \"com.lingewoud.wassup.pkg/Payload/WassUp.app/Contents/MacOS/WassUp\", \"com.lingewoud.wassup.pkg/Payload/WassUp.app/Contents/Resources/imagesnap\" )] Refer to App Sandbox page at https://developer.apple.com/devcenter/mac/app-sandbox/ for more information on sandboxing your app.

voeg toe aan Rakefile:
```
  app.entitlements['com.apple.security.app-sandbox'] = true
```


