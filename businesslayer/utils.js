(function() {

  exports.escapeQuote = function(s) {
    return this.replaceAll(s, "'", "&apos;");
  };

  exports.sanitizeSlashes = function(key, value) {
    if (typeof value === "string") {
      if ((value.indexOf("\r") !== -1) || (value.indexOf("\n") !== -1) || (value.indexOf("\t") !== -1) || (value.indexOf('"') !== -1)) {
        value = utils.replaceAll(value, "\r\n", "<br>");
        value = utils.replaceAll(value, "\r", "<br>");
        value = utils.replaceAll(value, "\n", "<br>");
        value = utils.replaceAll(value, "\t", "    ");
        return utils.replaceAll(value, '"', "&quot;");
      } else {
        return value;
      }
    } else {
      return value;
    }
  };

  exports.replaceAll = function(s, replaceThis, withThis) {
    var regexp;
    regexp = new RegExp(replaceThis, 'gi');
    return s.replace(regexp, withThis);
  };

}).call(this);
