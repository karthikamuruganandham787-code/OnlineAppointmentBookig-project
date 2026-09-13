package com.project3.util;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * Formats database TIME values (24-hour) as AM/PM for the UI.
 */
public final class TimeFormat {

    private static final DateTimeFormatter AMPM =
            DateTimeFormatter.ofPattern("hh:mm a", Locale.US);

    private TimeFormat() {
    }

    public static String toAmPm(String hhmm) {
        if (hhmm == null || hhmm.trim().isEmpty()) {
            return "-";
        }
        String trimmed = hhmm.trim();
        if (trimmed.length() >= 8) {
            trimmed = trimmed.substring(0, 5);
        } else if (trimmed.length() > 5) {
            trimmed = trimmed.substring(0, 5);
        }
        try {
            return LocalTime.parse(trimmed).format(AMPM).toUpperCase(Locale.US);
        } catch (Exception e) {
            return hhmm;
        }
    }

    public static String range(String start, String end) {
        return toAmPm(start) + " - " + toAmPm(end);
    }
}
