exports.escapeQuote = (s) ->
  @replaceAll(s, "'", "&apos;");

exports.sanitizeSlashes = (key, value) ->
  if (typeof value is "string") 
    if ((value.indexOf("\r") != -1) || (value.indexOf("\n") != -1) || (value.indexOf("\t") != -1) || (value.indexOf('"') != -1))
      value = utils.replaceAll(value, "\r\n", "<br>");
      value = utils.replaceAll(value, "\r", "<br>");
      value = utils.replaceAll(value, "\n", "<br>");
      value = utils.replaceAll(value, "\t", "    ");
      return utils.replaceAll(value, '"', "&quot;");
    else
      return value
  else
    return value

exports.replaceAll = (s, replaceThis, withThis) ->
  regexp = new RegExp(replaceThis, 'gi')
  s.replace(regexp,withThis)