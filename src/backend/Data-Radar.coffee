Data_Project = require '../../src/backend/Data-Project'
Data_Team    = require '../../src/backend/Data-Team'

class Data_Radar

  constructor: (options)->    
    @.options      = options || {}
    @.score_Initial = 0
    @.score_Yes     = 1
    @.score_Most   = 0.66
    @.score_Some   = 0.33
    @.score_No   = 0
    @.score_Max     = 3
    @.key_Yes       = 1
    @.key_Most     = 0.66
    @.key_Some     = 0.33
    @.key_No     = ''
    @.data_Project  = new Data_Project()
    @.data_Team     = new Data_Team()


  get_Radar_Fields: (project)=>

    result = axes : []
    schema = @.data_Project.project_Schema project
    offsets = [35, 10, 0, 13, 15, 15, -20, -20, 0, -5, -15 ,20]
    for name, practice of schema.practices
      result.axes.push
          axis      : practice.key,
          key       : practice.key,
          name      : name
          xOffset   : offsets.pop(),
          value     : 0
          size      : practice.activities.size()
    return result


  get_Radar_Data: (project, team)=>
    team_Data    = @.data_Team.get_Team_Data project, team
    radar_Fields = @.get_Radar_Fields project
    data         = @.map_Data radar_Fields, team_Data
    result       = axes: []
    for field in radar_Fields.axes
      result.axes.push { value: data[field.key]   }
    return result

  map_Data: (radar_Fields, team_Data)=>
    calculate = (prefix)=>
      score  = 0
      result = prefix: prefix, count :0 , yes_Count : 0, most_Count : 0, some_Count : 0, no_Count : 0

      for item in radar_Fields.axes when prefix.starts_With item.key              # todo: find better solution to get this value
        result.count = item.size

      for key,data of team_Data?.activities when key.starts_With(prefix)           #
        value = data.value
        #console.log {value}
        #console.log {prefix}
        #result.count++
        if value == @.key_Yes                                                       # add Yes value 1
          result.yes_Count++
        if value == @.key_Most                                                     # add Most value 0.66
          result.most_Count++
        if value == @.key_Some                                                     # add Some value 0.33
          result.some_Count++
        if value == @.key_No                                                     # add No value 0
          result.no_Count++
          
      score = ((result.yes_Count * @.score_Yes) + (result.most_Count * @.score_Most)+ (result.some_Count * @.score_Some)+ (result.no_Count * @.score_No)) / result.count
      #console.log {result.count}
      if score
        return (score * @.score_Max).to_Decimal()                                   # use to_Decimal, due to JS Decimal addition bug
      return 0.1


    result = {}
    for field in radar_Fields.axes
      result[field.key] = calculate field.key + "."
    return result

module.exports = Data_Radar
