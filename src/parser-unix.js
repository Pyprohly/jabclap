
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

function newNamedArgument() {
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
}

RegExp.escapePattern = /[-\/\\^$*+?.()|[\]{}]/g
RegExp.escape = function(s) {
	return s.replace(RegExp.escapePattern, '\\$&')
}

var args = WScript.Arguments
var wsh = new ActiveXObject('WScript.Shell')

var pairsExpected = wsh.Environment('Process')('JABCLAP_EXPECT_VALUE_FROM')
var caseSensitive = parseInt(wsh.Environment('Process')('JABCLAP_CASE_SENSITIVE'))
if (isNaN(caseSensitive)) { caseSensitive = true }
var bundleFlags = parseInt(wsh.Environment('Process')('JABCLAP_FLAG_BUNDLING'))
if (isNaN(bundleFlags)) { bundleFlags = true }
var pairIndicator = wsh.Environment('Process')('JABCLAP_KEY_INDICATOR') || '-'
var pairDelimiter = wsh.Environment('Process')('JABCLAP_PAIR_DELIMITER') || '= '

var pairsExpectedList = (caseSensitive ? pairsExpected : pairsExpected.toLowerCase()).split(' ')
var seen = {}
var expectingKeyValue = false
var pC = 0, nC = 0, qC = 0
var endOfOptions = /^\s+$/.test(pairIndicator)

for (i = 0; i < args.length; i++) {
	var arg = args.Item(i)
	WScript.Echo('[@' + (i + 1) + ']=' + arg)

	if (arg === '--') {
		endOfOptions = true
		continue
	}

	if (expectingKeyValue) {
		expectingKeyValue = false
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

	if (!endOfOptions && namedArgument(arg)) {
		var ind = arg.charAt(0)
		var akey = arg.slice(1)
		var d = arg.search(new RegExp('[' + RegExp.escape(pairDelimiter) + ']'))
		var sep = arg.charAt(d)
		var key = ~d ? arg.slice(1, d) : akey
		var lkey = key.toLowerCase()
		var value = ~d ? akey.slice(d) : ''

		if (~pairsExpectedList.indexOf(caseSensitive ? key : lkey)) {
			newNamedArgument()
			if (value) {
				WScript.Echo(
					"['" + key + "']=" + value
					+ "\n['" + key + "'" + seen[lkey] + ']=' + value
				)
			} else {
				WScript.Echo(
					"['" + key + "']="
				)
				if (~pairDelimiter.indexOf(' ')) {
					expectingKeyValue = true
				}
			}
		} else if (bundleFlags && (/[a-z0-9]/i.test(arg.charAt(1)))) {
			for (var k = 0; k < akey.length; k++) {
				key = akey.charAt(k)
				lkey = key.toLowerCase()

				// Stop processing flags at the first non-alphanumeric
				if (/[^a-z0-9]/i.test(key)) {
					break
				}

				newNamedArgument()

				if (~pairsExpectedList.indexOf(key)) {
					value = akey.slice(k + 1)
					if (value) {
						WScript.Echo(
							"['" + key + "']=" + value
							+ "\n['" + key + "'" + seen[lkey] + ']=' + value
						)
					} else {
						if (~pairDelimiter.indexOf(' ')) {
							expectingKeyValue = true
						}
						WScript.Echo(
							"['" + key + "']="
						)
					}
					break
				} else {
					WScript.Echo(
						"['" + key + "']=1"
						+ "\n['" + key + "'" + seen[lkey] + ']=1'
					)
				}
			}
		} else {
			newNamedArgument()

			WScript.Echo(
				"['" + akey + "']=1"
				+ "\n['" + akey + "'" + seen[lkey] + ']=1'
			)
		}
	} else {
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
	+ '\n[m]=unix'
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
