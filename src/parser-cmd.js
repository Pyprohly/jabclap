
Array.prototype.indexOf = function(needle) {
	for (var i = 0; i < this.length; i++) {
		if (this[i] === needle) {
			return i
		}
	}
	return -1
}

function namedArgument(str) {
	if (str.length < 2) { return false }
	return ~pairIndicator.indexOf(str.charAt(0)) ? true : false
}

RegExp.escapePattern = /[-\/\\^$*+?.()|[\]{}]/g
RegExp.escape = function(s) {
	return s.replace(RegExp.escapePattern, '\\$&')
}

var args = WScript.Arguments
var wsh = new ActiveXObject('WScript.Shell')

var pairsExpected = wsh.Environment('Process')('JABCLAP_EXPECT_VALUE_FROM')
var caseSensitive = parseInt(wsh.Environment('Process')('JABCLAP_CASE_SENSITIVE'))
var pairIndicator = wsh.Environment('Process')('JABCLAP_KEY_INDICATOR') || '/'
var pairDelimiter = wsh.Environment('Process')('JABCLAP_PAIR_DELIMITER') || ':='
var endOfOptionsMarker = wsh.Environment('Process')('JABCLAP_END_OF_OPTIONS_MARKER')
if (/^\s+$/.test(endOfOptionsMarker)) { endOfOptionsMarker = false }

var pairsExpectedList = (caseSensitive ? pairsExpected : pairsExpected.toLowerCase()).split(' ')
var seen = {}
var expectingKeyValue = false
var pC = 0, nC = 0, qC = 0
var endOfOptions = /^\s+$/.test(pairIndicator)

for (i = 0; i < args.length; i++) {
	var arg = args.Item(i)
	WScript.Echo('[@' + (i + 1) + ']=' + arg)

	if (endOfOptionsMarker && (arg === endOfOptionsMarker)) {
		endOfOptions = true
		continue
	}

	if (expectingKeyValue) {
		expectingKeyValue = false
		// Perhaps a good idea to check that it's not a named argument
		if (!namedArgument(arg)) {
			WScript.Echo(
				"[-'" + key + "']=" + ind
				+ "\n[-'" + key + "'" + seen[key] + ']=' + ind
				+ "\n['" + key + "']=" + arg
				+ "\n['" + key + "'" + seen[key] + ']=' + arg
			)
			continue
		}
	}

	// Not `else if` here because we still want to capture a named argument
	// even if we were expecting a non-named argument
	if (!endOfOptions && namedArgument(arg)) {
		// Attempt to split against any of the delimiters into a `key` and `value` part
		var ind = arg.charAt(0)
		var akey = arg.slice(1)
		var d = arg.search(new RegExp('[' + RegExp.escape(pairDelimiter) + ']'))
		// var sep = arg.charAt(d)
		var key = ~d ? arg.slice(1, d) : akey
		var lkey = key.toLowerCase()
		// var ckey = key
		// if (!caseSensitive) { ckey = lkey }
		var value = ~d ? akey.slice(d) : ''

		nC++

		if (seen.hasOwnProperty(lkey)) {
			seen[lkey]++
		} else {
			seen[lkey] = 1
			WScript.Echo(
				'[;' + ++qC + ']=' + key
			)
		}

		WScript.Echo(
			"[#'" + key + "']=" + seen[lkey]
			+ "\n[?'" + key + "']=1"
			+ "\n[?'" + key + "'" + seen[lkey] + ']=1'
			+ "\n[-'" + key + "']=" + ind
			+ "\n[-'" + key + "'" + seen[lkey] + ']=' + ind
		)

		if (caseSensitive) {
			WScript.Echo(
				'[`' + lkey + '`' + seen[lkey] + ']=' + key
				+ '\n[`' + lkey + '`]=' + key
			)
		}

		if (~pairsExpectedList.indexOf(caseSensitive ? key : lkey)) {
			// It is a key-value pair
			if (value) {
				WScript.Echo(
					"['" + key + "']=" + value
					+ "\n['" + key + "'" + seen[lkey] + ']=' + value
				)
			} else {
				if (~pairDelimiter.indexOf(' ')) {
					// A value could not be found for the key-value pair, but
					// if a space is one of the delimiters then we expect the
					// next argument to be the value...
					expectingKeyValue = true
				}
				// It's the most recent named argument that counts,
				// so if it was previously set then unset it now.
				WScript.Echo(
					"['" + key + "']="
				)
			}
		} else {
			// It is a switch
			WScript.Echo(
				"['" + akey + "']=1"
				+ "\n['" + akey + "'" + seen[lkey] + ']=1'
			)
		}
	} else {
		// It is a positional argument
		WScript.Echo(
			'[' + ++pC + ']=' + arg
		)
	}
}

var fso = new ActiveXObject('Scripting.FileSystemObject')
var scriptName = WScript.ScriptName.replace(/\?\.wsf$/i, '')
var scriptFullName = WScript.ScriptFullName.replace(/\?\.wsf$/i, '')

WScript.Echo(
	'[v]=1.0'
	+ '\n[m]=cmd'
	+ '\n[0]=' + scriptName
	+ '\n[~n0]=' + fso.GetBaseName(scriptName)
	+ '\n[~x0]=' + '.' + fso.GetExtensionName(scriptName)
	+ '\n[~nx0]=' + scriptName
	+ '\n[~f0]=' + scriptFullName
	+ '\n[~d0]=' + fso.GetDriveName(scriptFullName)
	+ '\n[~dp0]=' + fso.GetParentFolderName(scriptFullName)
	+ '\n[#a]=' + i
	+ '\n[#@]=' + i
	+ '\n[#p]=' + pC
	+ '\n[#]=' + pC
	+ '\n[#n]=' + nC
	+ '\n[#q]=' + qC
	+ '\n[#;]=' + qC
)
