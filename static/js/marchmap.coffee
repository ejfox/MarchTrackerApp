###
marchevents =[ 
    {
        location: "Snow Park"
        text: "This thing happened in this particular area and it was like WOAH!"
        onroute: true
        img: "http://www.csmonitor.com/var/ezflow_site/storage/images/media/images/1026-occupy-wall-street-occupy-oakland-tear-gas/10874029-1-eng-US/1026-occupy-wall-street-occupy-oakland-tear-gas_full_600.jpg"                
        time: "6:30PM"
    }
    {
        location: "14th and Clay"
        text: "Another thing over here! Woahhhhh!"
        onroute: true
        time: "6:44PM"
    }
    {
        location: "Washington and 7th"
        text: "And then THIS thing!"
        img: "http://www.nypost.com/rw/nypost/2011/11/03/news/web_photos/occupy_oakland--300x300.jpg"        
        onroute: true
        time: "7:00PM"
    }
    {
        location: "Clay and 8th"
        text: "Oh goodness!"
        img: "http://www.motherjones.com/files/images/occupy-oakland-wheelchair.jpg"        
        onroute: true
        time: "7:15PM"
    }
    
    {
        location: "Oak St. & 14th"
        text: "Imageless thing"    
        onroute: true
        time: "9:15PM"
    }
    
]
###

city = "Oakland, CA"


fillOutEvents = (marchevents) ->
    

    defaultZoom = 16

    map = new GMaps({
    div: '#map'
    lat: 37.804364
    lng: -122.271114
    zoom: defaultZoom
    zoomControl : true
    zoomControlOpt: {
        style : 'SMALL'
        position: 'TOP_LEFT'
    }
    panControl : false
    streetViewControl : false
    mapTypeControl: false
    overviewMapControl: false
    })

    infoWindow = new google.maps.InfoWindow({});      

    $(".mapzoomreset").on("click", -> map.setZoom(defaultZoom))


    #
    # Make D3 timeline
    #
    width = 1100
    height = 50

    new Date(2012, 9, 2, )
    longdateformat = d3.time.format("%y%m%d%H%M%S")      

    decodeTime = (datestring) ->
        if datestring isnt null or "" or "null" or "Time" 
            Date.parse(datestring)
        else
            console.log "Problem with the datestring, it could be null or an improper value."
            return false
        
    starttime = _.min(marchevents, (event) ->
        decodeTime(event.time)
    )
    starttime = decodeTime(starttime.time)

    endtime = _.max(marchevents, (event) ->
        decodeTime(event.time)
    )
    endtime = decodeTime(endtime.time)
    


    svg = d3.select("#timeline").attr("width", width).attr("height", height)




    console.log "timesszes", starttime, endtime

    timescale = d3.time.scale()
      .domain([starttime, endtime])
      .range([12, width-12])

    xAxis = d3.svg.axis().scale(timescale).orient("bottom").ticks(5).tickSize(0).tickPadding(6)

    svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0, 28)')
        .style('font-size', 9)
        .style('opacity', 0.5)
        .call(xAxis);


    svg.append("svg:line")
      .attr("y1", 20)
      .attr("y2", 20)
      .attr("x1", 0)
      .attr("x2", width)
      .style("stroke-width", 2)
      .style("stroke", "#CCC")

    event = svg.selectAll(".event")
    .data(marchevents)
    .enter().append("svg:g").attr("class", "event")
        .attr("transform", (d,i) ->
            "translate("+timescale(Date.parse(d.time))+",20)"
        )
    
    event.append("svg:text")
        .text((d,i) ->
            d.time
        )
        .attr("text-anchor", "middle")
        .attr("transform", "translate(0, -10)")
        .style("font-size", 11)
    
    event.append("svg:circle")
      .attr("class", "eventcircle")
      .attr("r", 6)
      .style("opacity", 0.5)
      .attr("fill", "black")
      .attr("cx", (d,i) -> 
          #startTime = new Date();
          #time = d.time.match(/(\d+)(?::(\d\d))?\s*(p?)/)
          #startTime.setHours(parseInt(time[1]) + (time[3] ? 12 : 0) )
          #startTime.setMinutes( parseInt(time[2]) || 0 )

          #console.log "sturt", startTime
          #timescale(startTime)
          return 0
      )
  
      .attr("title", (d,i) ->
          d.text
      )
      .style("cursor", "pointer")
    #      .attr("cy", 20)
      .on("click", (thisevent) ->
          console.log(thisevent)
          map.setCenter(thisevent.lat, thisevent.lng)
          map.setZoom(18)

          boxLatLng = new google.maps.LatLng(thisevent.lat, thisevent.lng)                        
          infoBoxContent = (event) ->
              boxcontent = event.text
              if event.img isnt undefined
                  boxcontent += " <img style='width: 320px;' src='"+event.img+"' />"
              return boxcontent

          infoWindow.setOptions({
              maxWidth: 320
          })
          infoWindow.setContent(infoBoxContent(thisevent))
          infoWindow.setPosition(boxLatLng)
          infoWindow.open(map.map)
    )

    console.log 'events', marchevents
    #
    # Add events to map
    #
    _.each(marchevents, (event, i) ->
        #console.log "event:", event, i
        # Decode event's address into lat/lng
        GMaps.geocode({
          address: event.location+" "+city,
          callback: (results, status) ->
              if status is 'OK' 
                  latlng = results[0].geometry.location;

                  #map.setCenter(latlng.lat(), latlng.lng())                
                  #map.addMarker({
                  #  lat: latlng.lat()
                  #  lng: latlng.lng()
                  #})

                  # Add event's text to sidebar 
                  eventli = $("<li id='event-"+i+"'>"+event.text+" <small>"+event.location+" ["+event.time+"]</small></li>").on("click", (event) ->
                      marchevent_num = $(event.target).attr('id')
                      event_num = marchevent_num.split("-")[1]
                      thisevent = marchevents[parseInt(event_num)]

                      #console.log "->", marchevent_num, event_num, thisevent
                      map.setCenter(thisevent.lat, thisevent.lng)
                      map.setZoom(defaultZoom+1)

                      boxLatLng = new google.maps.LatLng(thisevent.lat, thisevent.lng)                        
                      infoBoxContent = (event) ->
                          boxcontent = event.text
                          if event.img isnt undefined
                              boxcontent += " <img style='width: 240px;' src='"+event.img+"' />"
                          return boxcontent

                      infoWindow.setOptions({
                          maxWidth: 320
                      })
                      infoWindow.setContent(infoBoxContent(thisevent))
                      infoWindow.setPosition(boxLatLng)
                      infoWindow.open(map.map)
                  )

                  if event.img isnt undefined and event.img isnt null and event.img isnt "http://"
                      console.log "this thang", event.img
                      eventli.append($("<img src='"+event.img+"' />"))
                  else
                      thisevent = marchevents[i]
                      #console.log "latlng", latlng, latlng.lat(), latlng.lng()
                      #console.log "thisevent", thisevent.lat, thisevent.lng, thisevent

                      url = GMaps.staticMapURL({
                        size: [320, 180],
                        zoom: defaultZoom+1
                        lat: latlng.lat(),
                        lng: latlng.lng(),
                        maptype: "hybrid",
                        markers: [
                          {lat: latlng.lat(), lng: latlng.lng(), size: 'small', color: 'red'}
                        ]
                      });

                      $('<img/>').attr('src', url).appendTo(eventli);

                  $("#event-list").prepend(eventli)                    
                  marchevents[i].lat = latlng.lat()
                  marchevents[i].lng = latlng.lng()

                  # Add event markers
                  map.addMarker({
                    lat: latlng.lat()
                    lng: latlng.lng()
                    title: event.text
                    flat: true
                    click: (e) ->
                      console.log "marker clicked", e
                      map.setCenter(e.position.Xa, e.position.Ya)
                      map.setZoom(18)

                      boxLatLng = new google.maps.LatLng(latlng.lat(), latlng.lng())                        
                      infoBoxContent = (event) ->
                          boxcontent = event.text
                          if event.img isnt undefined
                              boxcontent += " <img style='width: 320px;' src='"+event.img+"' />"
                          return boxcontent

                      infoWindow.setOptions({
                          maxWidth: 320
                      })
                      infoWindow.setContent(infoBoxContent(event))
                      infoWindow.setPosition(boxLatLng)
                      infoWindow.open(map.map)
                  })    
          
                  $('#summary').trunk8({
                      lines: 3
                  })
          
          
                  # Skip the first event

                  if i isnt 0 and event.onroute is true
                    prevEvent = marchevents[i-1]

                    #console.log "Drawin' Origin: ", event.lat, event.lng
                    #console.log "Drawin' Destination", prevEvent.lat, prevEvent.lng
                    #console.log "prevEvent", prevEvent

                    map.drawRoute({
                      origin: [event.lat, event.lng],
                      destination: [prevEvent.lat, prevEvent.lng],
                      travelMode: 'walking',
                      strokeColor: '#131540',
                      strokeOpacity: 0.6,
                      strokeWeight: 6
                    })       
        })
    )#End _.each(marchevents)

    
$(document).ready(->        
        eventid = $('#eventnumber').val();
        
#        $('body').prepend("Loading "+eventid)

        $.ajax('/listevents?eventid='+eventid, {
          type: 'GET'
          dataType: 'json'
          success: (data) ->
              marchevents = data
              console.log "THIS IS A MARCHHHHEVENTTTT", marchevents
              fillOutEvents(marchevents)
          error: ->
              return null
        })
      


)#End $(document).ready()