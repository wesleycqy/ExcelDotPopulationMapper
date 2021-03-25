# Wesley Chong
# Chapter 10 - 13 Assignment Part 2
# Dr David Owen

include gdrive-sheets
include image

ssid = "1e84tbj8g6ngx3-NPWm_bWvuPA8aF8Ok6dfNkqxaNLs4"
cities =
  load-table: city, state, latitude, longitude, population
    source: load-spreadsheet(ssid).sheet-by-name("US Cities", true)
  end

# checks for cities bigger than 100,000 population
fun big-enough(r :: Row) -> Boolean:
  r["population"] >= 100000
end 
citiesFiltered = cities.filter(big-enough) # adds cities bigger than 100,00 to citiesFiltered table

# Range of latitude and longitude for continental US.
MIN_LAT = 25 # Y-Min
MAX_LAT = 49 # Y-Max
MIN_LON = -125 # X-Min
MAX_LON = -67 # X-Max

# You'll be able to adjust this to get a different size output image.
SCALE = 10

# Set image height and width based on latitude and longitude ranges.
H = ((MAX_LAT - MIN_LAT) * SCALE) # Y
W = ((MAX_LON - MIN_LON) * SCALE) # X


# adds Y axis value to table
fun cities-addY(r :: Row) -> Number:
  ((r["latitude"] - MIN_LAT) / (MAX_LAT - MIN_LAT)) * H
end
cities-Y = citiesFiltered.build-column("Y", cities-addY)


# adds X axis value to table
fun cities-addX(r :: Row) -> Number:
  ((r["longitude"] - MIN_LON) / (MAX_LON - MIN_LON)) * W
end
cities-XY = cities-Y.build-column("X", cities-addX)


maxPop = 18713220
minPop = 100049

# adds population value to table as circle radius size
fun cities-addRadius(r :: Row) -> Number:
  radiusAdd = (((r["population"] - minPop)  / (maxPop - minPop) ) * SCALE)
  if radiusAdd < 1: 1
  else: radiusAdd
  end
end
cities-final = cities-XY.build-column("radius", cities-addRadius)


data Dot:
  | dot(x, y, r)
end

# Make a dot from r["x"], r["y"] and r["radius"].
fun make-dot(r :: Row) -> Dot:
  dot(r["X"],r["Y"],r["radius"])
end


citiesTableDot = cities-final.build-column("dot", make-dot) # adds dot to table
citiesList = citiesTableDot.get-column("dot") # changes table to a list form

#prints the dots
fun put-dots(m):
  cases (List) m:
    | empty => 
      empty-scene(W, H)
    | link(f, r) =>
      c = circle(f.r, "solid", "blue")
      put-image(c, f.x, f.y, put-dots(r))
      end
end

USMap = image-url("https://media.defense.gov/2003/Apr/24/2001497063/-1/-1/0/24-F-ZZ999-094.jpg")
USMapScaled = scale-xy((W / 1800), (H / 1079), USMap)

# put-dots(citiesList) #uncomment this to view dots alone



underlay-align("middle", "middle",USMapScaled, put-dots(citiesList))
