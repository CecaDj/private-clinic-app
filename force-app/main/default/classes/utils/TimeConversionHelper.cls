public without sharing class TimeConversionHelper {

    // Converts Time → String ("03:30 PM")
    public static String convert(Time t) {

        if (t == null) {
            return '';
        }

        Integer h24 = t.hour();
        Integer m = t.minute();

        String ampm = (h24 >= 12) ? 'PM' : 'AM';
        Integer h12 = Math.mod(h24, 12);
        if (h12 == 0) {
            h12 = 12;
        }

        String hh = (h12 < 10 ? '0' : '') + h12;
        String mm = (m < 10 ? '0' : '') + m;

        return hh + ':' + mm + ' ' + ampm;
    }    
    

    // Converts String ("03:30 PM") → Time
    public static Time convert(String input) {
        if (String.isBlank(input)) {
            throw new AuraHandledException('Invalid time format.');
        }

        String s = input.trim().toUpperCase();
        if (!(s.endsWith('AM') || s.endsWith('PM'))){
            throw new AuraHandledException('Please include AM or PM (e.g., "9:30 AM").');
        }

        String mer = s.endsWith('AM') ? 'AM' : 'PM';
        s = s.replace('AM', '').replace('PM', '').trim();

        List<String> parts = s.split(':');
        if (parts.size() != 2) {
            throw new AuraHandledException('Invalid format. Use "h:mm AM/PM".');
        }

        Integer hour12 = Integer.valueOf(parts[0]);
        Integer minute = Integer.valueOf(parts[1]);
        if (hour12 < 1 || hour12 > 12 || minute < 0 || minute > 59){
            throw new AuraHandledException('Invalid time value.');
        }

        Integer hour24 = (mer == 'PM' && hour12 != 12) ? hour12 + 12 :
                         (mer == 'AM' && hour12 == 12) ? 0 : hour12;

        return Time.newInstance(hour24, minute, 0, 0);
        
    }
}
