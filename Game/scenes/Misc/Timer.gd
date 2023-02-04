extends HBoxContainer


export(bool) var show_plus = false
export(int) var decimal = 2

var start
var time = 0

var running = true

# Called when the node enters the scene tree for the first time.
func _ready():
    start = OS.get_ticks_msec()
    set_decimals()
    set_time()

func _process(_delta):
    if running:
        set_time()


func set_time():
    var now = OS.get_ticks_msec()
    time = (now - start)/1000.0
    var hours = int(time / 3600)
    var minutes = int((time-hours*3600)/60)
    var seconds = (time-hours*3600-minutes*60)
    
    var hour1000 = floor(hours/1000)
    var hour100 = floor((hours%1000)/100)
    var hour10 = floor((hours%100)/10)
    var hour = hours%10
    
    var minute10 = floor(minutes/10)
    var minute = minutes%10
    
    var second10 = floor(seconds/10)
    var second = int(seconds)%10
    
    var tens = floor((seconds-int(seconds))*10)
    var hundreds = int((seconds-int(seconds))*100)%10
    if time < 0:
        $Sign.text = "-"
    elif time > 0 and show_plus:
        $Sign.text = "+"
    else:
        $Sign.text = ""
    $Hour/Number.text = str(hour)
    $Hour10/Number.text = str(hour10)
    $Hour100/Number.text = str(hour100)
    $Hour1000/Number.text = str(hour1000)
    $Minute/Number.text = str(minute)
    $Minute10/Number.text = str(minute10)
    $Second/Number.text = str(second)
    $Second10/Number.text = str(second10)
    $Tens/Number.text = str(tens)
    $Hundreds/Number.text = str(hundreds)
    
    if hour1000 == 0:
        $Hour1000.hide()
        if hour100 == 0:
            $Hour100.hide()
            if hour10 == 0:
                $Hour10.hide()
                if hour == 0:
                    $Hour.hide()
                    $HourSeparator.hide()
                    if minute10 == 0:
                        $Minute10.hide()
                        if minute == 0:
                            $Minute.hide()
                            $MinuteSeparator.hide()
                            if second10 == 0:
                                $Second10.hide()
                            else:
                                $Second10.show()
                        else:
                            $Minute.show()
                            $MinuteSeparator.show()
                    else:
                        $Minute10.show()
                else:
                    $Hour.show()
                    $HourSeparator.show()
            else:
                $Hour10.show()
        else:
            $Hour100.show()
    else:
        $Hour1000.show()
        
func set_decimals():
    match decimal:
        0:
            $SecondSeparator.hide()
            $Tens.hide()
            $Hundreds.hide()
        1:
            $SecondSeparator.show()
            $Tens.show()
            $Hundreds.hide()
        2:
            $SecondSeparator.show()
            $Tens.show()
            $Hundreds.show()
            
            
                                
            
