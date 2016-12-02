<?php
/*
 * This script creates a list of php -d arguments depended from available PHP_INI_ environment variables.
 *
 * "PHP_INI_DATE_TIMEZONE=Europe/Berlin" will be translated to "-ddate.timezone=Europe/Berlin".
 * "PHP_INI_MAX_EXECUTION_TIME=30" will be translated to "-dmax_execution_time=30".
 *
 * The right wording will be fetched from available ini settings.
 */

$attributes    = [];
$availableKeys = [];

// Prepare ini keys
foreach (array_keys(ini_get_all()) as $key) {
    $availableKeys[cleanKey($key)] = $key;
}

foreach ($_SERVER as $key => $value) {
    if (strpos($key, 'PHP_INI_') === 0) {
        $key = cleanKey(substr($key, 8));

        if (isset($availableKeys[$key])) {
            $attributes[] = '-d' . $availableKeys[$key] . '=' . $value;
        }
    }
}

if (count($attributes)) {
    echo implode(' ', $attributes);
}

exit(0);

/**
 * Cleans the key from non-alpha signs.
 *
 * @param string $key
 *
 * @return string
 */
function cleanKey($key)
{
    return strtolower(preg_replace("#[^a-z]#is", "", $key));
}