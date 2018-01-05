({
    doInit:function(component,event){
        console.log("hii");
        
        var existingDate = component.get("v.value");
        if(existingDate){
        if(existingDate.indexOf('AM') || existingDate.indexOf('PM')){
            
            var hour,min,mer,tz;
            
            if(component.get('v.isTimePicker') && component.get('v.isDatePicker')){
                
                console.log("in helper do init");
                hour = existingDate.substring(11,13);
                min = existingDate.substring(14,16);
                mer = existingDate.indexOf('AM')?'AM':'PM';
                tz = existingDate.substring(20);
                console.log("hh");
            }
            
            
            else if(component.get('v.isTimePicker') && !component.get('v.isDatePicker')){
                
                console.log("in helper do init");
                hour = existingDate.substring(0,2);
                min =  existingDate.substring(3,5);
                mer = existingDate.indexOf('AM')?'AM':'PM';
                tz = existingDate.substring(9);
                
              }
            
            component.set('v.hour',hour);
            component.set('v.min',min);
            component.set('v.meridian',mer);
            component.set('v.timezone',tz);
            
              
           }
        }
    },
    changeTime:function(component, event){
        
        isTimePicker = component.get('v.isTimePicker');
        isDatePicker = component.get('v.isDatePicker');
        
        if(isTimePicker && isDatePicker){
                var currentValue = component.get("v.value");
             
                var dateStr = currentValue.substring(0,10);
                
               
                var newYear = new Date(dateStr).getFullYear();
                var newMonth = (new Date(dateStr).getMonth())<10?'0'+(new Date(dateStr).getMonth()+1):(new Date(dateStr).getMonth()+1);
                var newDate = (new Date(dateStr).getDate())<10?'0'+(new Date(dateStr).getDate()):(new Date(dateStr).getDate());
                
                var newDate = newMonth+'/'+newDate+'/'+newYear;
                
                var hour = component.get("v.hour");
                var minutes = component.get("v.min");
                var mer = component.get("v.meridian");
                var tz = component.get("v.timezone");
                
                var newTime = hour+':'+minutes+' '+mer+' '+tz;
                var v = newDate+' '+newTime;
                console.log(v);
                component.set("v.value",newDate+' '+newTime);
        }
        
        else if (!isTimePicker && isDatePicker){
            console.log("only date picker");
        }
        
        else if (isTimePicker && !isDatePicker){
            
            var hour = component.get("v.hour");
            var minutes = component.get("v.min");
            var mer = component.get("v.meridian");
            var tz = component.get("v.timezone");
            var newTime = hour+':'+minutes+' '+mer+' '+tz;
           
            console.log(newTime);
            component.set("v.value",''+newTime);
                
            
        }
        
        
        var grid = component.find("grid2");
         if(grid){
              $A.util.addClass(grid, 'slds-hide');
              $A.util.addClass(grid, 'slds-transition-hide');
              component.set("v.isTimepickerOpen", false);  
         }
    },
    
    changeYear: function(component, newYear, date) {
        try {
            var currentMonth = component.get("v.month");
            var currentYear = component.get("v.year");
            
            if (!currentYear) {
                currentYear = this.date.current.year();
            }
            
            var currentDate = new Date(currentYear, currentMonth, date);
            var targetDate = new Date( newYear,currentDate.getMonth(), 1);
            
            var daysInMonth = this.numDays(currentMonth, currentYear);
            
            if (daysInMonth < date) { // The target month doesn't have the current date. Just set it to the last date.
                date = daysInMonth;
            }
            this.setDateValues(component, targetDate, date);
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    changeMonth: function(component, monthChange) {
        try {
            var currentYear = component.get("v.year");
            var currentMonth = component.get("v.month");
            var currentDay = component.get("v.date");
            
            var currentDate = new Date(currentYear, currentMonth, currentDay);
            var targetDate = new Date(currentDate.getFullYear() , currentDate.getMonth() + monthChange, 1);
            
            var daysInMonth = this.numDays(currentMonth, currentYear);
            
            if (daysInMonth < currentDay) { // The target month doesn't have the current date. Just set it to the last date.
                currentDay = daysInMonth;
            }
            this.setDateValues(component, targetDate, currentDay);
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    
    goToToday: function(component, event) {
        try{
            var currentYear = this.date.current.year();
            var currentMonth = this.date.current.month.integer();
            var currentDay = this.date.current.day();
            
            var newYear = component.find("yearSelect").set("v.value",currentYear);
            
            var targetDate = new Date(currentYear,currentMonth, currentDay);
            this.setDateValues(component, targetDate, currentDay);
            
            var selectedDate = new Date(component.get("v.year"), component.get("v.month"), component.get("v.date"));
            var dateStr = component.get("v.year") + "-" + (component.get("v.month") + 1) + "-" + component.get("v.date");
            //var dateStr =  (component.get("v.month") + 1) + "/" + component.get("v.date") + "/" + component.get("v.year");
            component.set("v.selectedDate", selectedDate);
            component.set("v.value", dateStr );
            
            //finally fire the event to tell parent components we have changed the date:
            var dateChangeEvent = component.getEvent("dateChangeEvent");
            dateChangeEvent.setParams({"value" : dateStr });
            dateChangeEvent.fire();
            
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    dateCompare: function(date1, date2) {
        try {
            if (date1.getFullYear() !== date2.getFullYear()) {
                return date1.getFullYear() - date2.getFullYear();
            } else {
                if (date1.getMonth() !== date2.getMonth()) {
                    return date1.getMonth() - date2.getMonth();
                } else {
                    return date1.getDate() - date2.getDate();
                }
            }
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /**
   * Java style date comparisons. Compares by day, month, and year only.
   */
    dateEquals: function(date1, date2) {
        try {
            return date1 && date2 && this.dateCompare(date1, date2) === 0;
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /**
   * Find the cell component for a specific date in a month.
   * @date - Date object
   */
    findDateComponent: function(component, date) {
        try {
            var firstDate = new Date(date.getTime());
            firstDate.setDate(1);
            var initialPos = firstDate.getDay();
            var pos = initialPos + date.getDate() - 1;
            
            return component.find(pos);
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /**
   * generates the days for the current selected month.
   */
    generateMonth: function(component) {
        try {
            var dayOfMonth = component.get("v.date");
            var month = component.get("v.month");
            var year = component.get("v.year");
            var date = new Date(year, month, dayOfMonth);
            
            
            //var selectedDate = new Date(Date.UTC(year, month, dayOfMonth, 0, 0, 0));
            var selectedDate = new Date(year, month, dayOfMonth);
            
            var today = new Date();
            var d = new Date();
            d.setDate(1);
            d.setFullYear(year);
            d.setMonth(month);
            // java days are indexed from 1-7, javascript 0-6
            // The startPoint will indicate the first date displayed at the top-left
            // corner of the calendar. Negative dates in JS will subtract days from
            // the 1st of the given month
            var firstDayOfWeek = $A.get("$Locale.firstDayOfWeek") - 1; // In Java, week day is 1 - 7
            var startDay = d.getDay();
            var firstFocusableDate;
            while (startDay !== firstDayOfWeek) {
                d.setDate(d.getDate() - 1);
                startDay = d.getDay();
            }
            //HH
            for (var i = 0; i < 42; i++) {
                var cellCmp = component.find(i);
                if (cellCmp) {
                    var dayOfWeek = d.getDay();
                    var tdClass = '';
                    
                    if (d.getMonth() === month - 1 || d.getFullYear() === year - 1) {
                        cellCmp.set("v.ariaDisabled", "true");
                        tdClass = 'slds-disabled-text';
                    } else if (d.getMonth() === month + 1 || d.getFullYear() === year + 1) {
                        cellCmp.set("v.ariaDisabled", "true");
                        tdClass = 'slds-disabled-text';
                    }
                    
                    if (d.getMonth() === month && d.getDate() === 1) {
                        firstFocusableDate = cellCmp;
                    }
                    
                    if (this.dateEquals(d, today)) {
                        tdClass += ' slds-is-today';
                    }
                    if (this.dateEquals(d, selectedDate)) {
                        cellCmp.set("v.ariaSelected", "true");
                        tdClass += ' slds-is-selected';
                        firstFocusableDate = cellCmp;
                    }
                    
                    cellCmp.set("v.tabIndex", -1);
                    cellCmp.set("v.label", d.getDate());
                    cellCmp.set("v.tdClass", tdClass)
                    
                    var dateStr = d.getFullYear() + "-" +
                        ('0' + (d.getMonth() + 1)).slice(-2) + "-" +
                        ('0' + d.getDate()).slice(-2);
                    // var dateStr =  ('0' + (d.getMonth() + 1)).slice(-2) + "/" +
                    //   ('0' + d.getDate()).slice(-2) + "/" + d.getFullYear() ;
                    cellCmp.set("v.value", dateStr);
                    
                }
                d.setDate(d.getDate() + 1);
            }
            if (firstFocusableDate) {
                firstFocusableDate.set("v.tabIndex", 0);
            }
            component.set("v._setFocus", true);
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    getEventTarget: function(e) {
        try {
            return (window.event) ? e.srcElement : e.target;
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    displayDatePicker:function(component, event){
      if(component.get('v._gridOver')===false){
      var grid = component.find("grid");
     	var displayDatePicker = component.get("v.isDatepickerOpen");
       $A.util.toggleClass(grid, 'slds-hide');
        component.set("v.isDatepickerOpen",!displayDatePicker);
        var date = component.get("v.selectedDate");
    
    }
    },
    goToFirstOfMonth: function(component) {
        try {
            var date = new Date(component.get("v.year"), component.get("v.month"), 1);
            var targetId = date.getDay();
            var targetCellCmp = component.find(targetId);
            targetCellCmp.getElement().focus();
            component.set("v.date", 1);
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    goToLastOfMonth: function(component) {
        try {
            var date = new Date(component.get("v.year"), component.get("v.month") + 1, 0);
            var targetCellCmp = this.findDateComponent(component, date);
            if (targetCellCmp) {
                targetCellCmp.getElement().focus();
                component.set("v.date", targetCellCmp.get("v.label"));
            }
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    
    renderGrid: function(component) {
        try {
            this.generateMonth(component);
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    selectDate: function(component, event) {
        try {
            var source = event.getSource();
            
            var firstDate = new Date(component.get("v.year"), component.get("v.month"), 1);
            var firstDateId = parseInt(firstDate.getDay(), 10);
            
            // need to account for start of week differences when comparing indices
            var firstDayOfWeek = $A.get("$Locale.firstDayOfWeek") - 1; // The week days in Java is 1 - 7
            var offset = 0;
            if (firstDayOfWeek !== 0) {
                if (firstDateId >= firstDayOfWeek) {
                    offset -= firstDayOfWeek;
                } else {
                    offset += (7 - firstDayOfWeek);
                }
            }
            
            firstDateId += offset;
            var lastDate = new Date(component.get("v.year"), component.get("v.month") + 1, 0);
            var lastDateCellCmp = this.findDateComponent(component, lastDate);
            var lastDateId = parseInt(lastDateCellCmp.getLocalId(), 10);
            lastDateId += offset;
            
            var currentId = parseInt(source.getLocalId(), 10);
            var currentDate = source.get("v.label");
            var targetDate;
            if (currentId < firstDateId) { // previous month
                targetDate = new Date(component.get("v.year"), component.get("v.month") - 1, currentDate);
                this.setDateValues(component, targetDate, targetDate.getDate());
                
            } else if (currentId > lastDateId) { // next month
                targetDate = new Date(component.get("v.year"), component.get("v.month") + 1, currentDate);
                this.setDateValues(component, targetDate, targetDate.getDate());
                
            } else {
                component.set("v.date", currentDate);
            }
            var selectedDate = new Date(component.get("v.year"), component.get("v.month"), component.get("v.date"));
            var dateStr = component.get("v.year") + "-" + (component.get("v.month") + 1) + "-" + component.get("v.date");
            component.set("v.selectedDate", selectedDate);
            component.set("v.value", dateStr );
            //finally fire the event to tell parent components we have changed the date:
            var dateChangeEvent = component.getEvent("dateChangeEvent");
            dateChangeEvent.setParams({"value" : dateStr });
            dateChangeEvent.fire();
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    setFocus: function(component) {
        try {
            var date = component.get("v.date");
            if (!date) {
                date = 1;
            }
            var year = component.get("v.year");
            var month = component.get("v.month");
            var cellCmp = this.findDateComponent(component, new Date(year, month, date));
            if (cellCmp) {
                cellCmp.getElement().focus();
            }
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    updateNameOfWeekDays: function(component) {
        try {
            var firstDayOfWeek = $A.get("$Locale.firstDayOfWeek") - 1; // The week days in Java is 1 - 7
            var namesOfWeekDays = $A.get("$Locale.nameOfWeekdays");
            var days = [];
            if (this.isNumber(firstDayOfWeek) && $A.util.isArray(namesOfWeekDays)) {
                var len = namesOfWeekDays.length;
                for (var i = firstDayOfWeek; i < len; i++) {
                    days.push(namesOfWeekDays[i]);
                }
                for (var j = 0; j < firstDayOfWeek; j++) {
                    days.push(namesOfWeekDays[j]);
                }
                component.set("v._namesOfWeekdays", days);
            } else {
                component.set("v._namesOfWeekdays", namesOfWeekDays);
            }
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    isNumber: function(obj) {
        try {
            return !isNaN(parseFloat(obj))
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    numDays: function(currentMonth, currentYear) {
        try {
            // checks to see if february is a leap year otherwise return the respective # of days
            return currentMonth === 1 && (((currentYear % 4 === 0) && (currentYear % 100 !== 0)) || (currentYear % 400 === 0)) ? 29 : this.l10n.daysInMonth[currentMonth];
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    setDateValues: function(component, fullDate, dateNum) {
        try {
            component.set("v.year", fullDate.getFullYear());
            component.set("v.month", fullDate.getMonth());
            component.set("v.monthName", this.l10n.months.longhand[fullDate.getMonth()]);
            component.set("v.date", dateNum);
            component.set("v.selectedDate", fullDate);
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    generateYearOptions : function(component,fullDate) {
        try {
            var years = [];
            var startYear = component.get("v.startYear");
            var finishYear = component.get("v.finishYear");
            if (!component.get("v.extendedYearRange") || !startYear || !finishYear || ( startYear >= finishYear)   ){
                startYear = fullDate.getFullYear()-1;
                finishYear = startYear + 10
            }
            var thisYear = fullDate.getFullYear();
            
            for (var i = startYear; i <= finishYear; i++) {
                years.push({ "class": "optionClass", label: i, value: i });
            }
            try {
                years[thisYear].selected = true;
            }catch (e){
                //can't select this year, so don't worry 'bout it
            }
            
            component.set("v.options",years);
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    handleManualInput : function (component,event){
        try {
            var params = event.getParam('arguments');
            if (params) {
                var date = params.date;
                component.set("v.value",date);
                this.handleManualDateChange(component);
            }
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    handleManualDateChange : function (component){
        try {
            var format = component.get("v.formatSpecifier");
            var datestr = component.get("v.value");
            var langLocale = $A.get("$Locale.langLocale");
            
            //if a person has deliberately cleared the date, respect that.
            if ($A.util.isEmpty(datestr)){
                this.clearDate(component);
                return;
            }
            
            var currentDate = this.parseInputDate(component,datestr);
            this.setDateValues(component, currentDate, currentDate.getDate());
            
            // Set the first day of week
            this.updateNameOfWeekDays(component);
            this.generateYearOptions(component,currentDate);
            
            var selectedDate = new Date(component.get("v.year"), component.get("v.month"), component.get("v.date"));
            var dateStr = component.get("v.year") + "-" + (component.get("v.month") + 1) + "-" + component.get("v.date");
            //var dateStr = (component.get("v.month") + 1) + "/" + component.get("v.date") + "/" + component.get("v.year") ;
            component.set("v.selectedDate", selectedDate);
            component.set("v.value", dateStr );
            
            //finally fire the event to tell parent components we have changed the date:
            var dateChangeEvent = component.getEvent("dateChangeEvent");
            dateChangeEvent.setParams({"value" : dateStr });
            dateChangeEvent.fire();
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    clearDate: function(component) {
        try {
            component.set("v.selectedDate", '');
            component.set("v.value", '');
            /*added by sayari*/
            component.set('v.hour','');
            component.set('v.min','');
            component.set('v.meridian','');
            component.set('v.timezone','');
            /*added by sayari*/
            
            //finally fire the event to tell parent components we have changed the date:
            var dateChangeEvent = component.getEvent("dateChangeEvent");
            dateChangeEvent.setParams({"value" : '' });
            dateChangeEvent.fire();
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    parseInputDate : function(component,datestr){
        try {
            var parsedDate = $A.localizationService.parseDateTime(datestr, 'MM/DD/YYYY');
            var timezone = $A.get("$Locale.timezone");
            
            //ok try this format
            if (parsedDate === null || !this.isDateValid(parsedDate)) {
                parsedDate = $A.localizationService.parseDateTime(datestr, 'yyyy-MM-dd');
            }
            
            //try, try again
            if (parsedDate === null || !this.isDateValid(parsedDate)) {
                $A.localizationService.getToday(timezone, function(today) {
                    parsedDate = $A.localizationService.parseDateTime(today, 'yyyy-MM-dd');
                });
            }
            return parsedDate; 
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    isDateValid: function(date) {
        try {
            if (Object.prototype.toString.call(date) === "[object Date]") {
                // it is a date
                if (isNaN(date.getTime())) { // d.valueOf() could also work
                    // date is not valid
                    return false;
                } 
                else {
                    // date is valid
                    return true;
                }
            } 
            else {
                // not a date
                return false;
            }
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    
    l10n: {
        weekdays: {
            shorthand: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            longhand: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        },
        months: {
            shorthand: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            longhand: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
        },
        daysInMonth: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
        firstDayOfWeek: 0
    },
    
    date: {
        current: {
            year: function() {
                try {
                    return new Date().getFullYear();
                } catch(e) { 
                    this.consoleLog(e.stack, true); 
                }
            },
            month: {
                integer: function() {
                    try{
                        return new Date().getMonth();
                    } catch(e) { 
                        this.consoleLog(e.stack, true); 
                    }
                },
                string: function(shorthand) {
                    try{
                        var month = new Date().getMonth();
                        return monthToStr(month, shorthand);
                    } catch(e) { 
                        this.consoleLog(e.stack, true); 
                    }
                }
            },
            day: function() {
                return new Date().getDate();
            }
        }
    }
    
});