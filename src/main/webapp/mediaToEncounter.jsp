<jsp:include page="headerfull.jsp" flush="true"/>

<xlink rel="stylesheet" href="tools/jquery-ui/jquery-ui.css" id="theme">

<xlink href="tools/bootstrap/css/bootstrap.min.css" rel="stylesheet">
<!-- Default fonts for jquery-ui are too big
<style>
.ui-widget {
    font-size:90%;
}
</style> -->



<%
/*
    org.ecocean.survey.Survey survey = new org.ecocean.survey.Survey();
    survey.setComments("testing");
    survey.setEndTime(42l);
*/
/*     java.util.List<org.ecocean.survey.SurveyTrack> tracks = new java.util.ArrayList<org.ecocean.survey.SurveyTrack>();
    org.ecocean.survey.SurveyTrack track = new org.ecocean.survey.SurveyTrack();
    track.setName("bob");
    tracks.add(track);
    survey.setTracks(tracks);
 */
 /*
 org.ecocean.Encounter encounter = new org.ecocean.Encounter();
 encounter.setComments("testing");
 encounter.setDay(42);

    String context=org.ecocean.servlet.ServletUtilities.getContext(request);
    org.ecocean.Shepherd myShepherd = new org.ecocean.Shepherd(context);

    myShepherd.getPM().makePersistent(encounter);
*/
%>


<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript"  src="JavascriptGlobals.js"></script>

<script src="javascript/underscore-min.js"></script>
<script src="javascript/backbone-min.js"></script>
<script src="javascript/core.js"></script>
<script src="javascript/classes/Base.js"></script>


<style>
body { font-family: arial }

#admin-div {
	margin-top: 10px;
	display: none;
}
#work-div {
	display: none;
}
.error { color: #F20 }

.thumb {
/*
	max-width: 150px;
	max-height: 120px;
*/
	width: 150px;
	height: 100px;
}

.image {
	background-color: #EEE;
	margin: 11px;
	position: relative;
	padding: 10px;
	display: inline-flex;
}

.note {
	text-align: center;
	position: absolute;
	bottom: -3px;
	right: -3px;
	border-radius: 12px;
	background-color: #8AC;
	color: white;
	font-weight: bold;
	padding: 3px 6px;
}

.image-info {
	text-align: center;
	position: absolute;
	top: 0;
	left: 0;
	border-radius: 2px;
	background-color: rgba(128,128,128,0.5);
	color: rgba(0,0,0,0.7);
	font-size: 0.7em;
	padding: 1px 4px;
}

.enc-list {
	display: none;
	position: fixed;
	top: 50px;
	right: 30px;
	border: solid 1px #AAA;
	padding: 10px;
	color: #555;
}

.status-new td, .status- td, .status-null td {
	background-color: #FFC !important;
}

.status-closed td {
	background-color: #DDD !important;
}

.image:hover {
	background-color: #9F0;
}

#images-used, #images-unused {
	min-height: 200px;
}

#images-unused {
	max-height: 400px;
	overflow-y: scroll;
}

#count-total {
	color: #555;
}
#count-used {
	margin-left: 15px;
}

#encounter-div {
	padding: 10px;
	border: solid 2px blue;
	margin-top: 10px;
}

#enc-form label {
	font-size: 0.8em;
	color: #555;
	display: inline-block;
	width: 120px;
	margin-right: 10px;
}

#enc-results {
	height: 11px;
	margin: 10px 0 0 10px;
	font-size: 0.8em;
}

</style>

<script src="//code.jquery.com/ui/1.11.2/jquery-ui.js"></script>
<link rel="stylesheet" href="//code.jquery.com/ui/1.11.2/themes/smoothness/jquery-ui.css">





<link rel="stylesheet" href="javascript/tablesorter/themes/blue/style.css" type="text/css" media="print, projection, screen" />

<link rel="stylesheet" href="css/pageableTable.css" />
<script src="javascript/tsrt.js"></script>




<style>
.ptcol-maxYearsBetweenResightings {
	width: 100px;
}
.ptcol-numberLocations {
	width: 100px;
}

</style>

<script type="text/javascript">



var colDefn = [
	{
		key: 'timeSubmitted',
		label: 'Submitted',
		value: _colTimeSubmitted,
		//sortValue: _colDateSort,
		//sortFunction: function(a,b) { return parseFloat(a) - parseFloat(b); }
	},
	{
		key: 'date',
		label: 'Date',
		value: _colDate,
		sortValue: _colDateSort,
		sortFunction: function(a,b) { return parseFloat(a) - parseFloat(b); }
	},
	{
		key: 'submitter',
		label: 'Submitted By',
		value: _colSubmitter,
	},
	{
		key: 'submissionid',
		label: 'Survey ID',
		value: cleanValue,
	},
	{
		key: 'description',
		label: 'Description',
		value: cleanValue,
	},
	{
		key: 'verbatimLocation',
		label: 'Location',
		value: cleanValue,
	},
	{
		key: 'status',
		label: 'Status',
		value: _colStatus,
		sortValue: _colStatusSort,
	},
/*
	{
		key: 'numberImages',
		label: '# images',
		value: _numImages,
	}
*/
	
];


var counts = {
	total: 0,
	ided: 0,
	unid: 0,
	dailydup: 0,
};


var howMany = 10;
var start = 0;
var results = [];

var sortCol = -1;
var sortReverse = true;


var sTable = false;

function doTable() {
	sTable = new SortTable({
		data: searchResults,
		perPage: howMany,
		sliderElement: $('#results-slider'),
		columns: colDefn,
	});

	$('#results-table').addClass('tablesorter').addClass('pageableTable');
	var th = '<thead><tr>';
		for (var c = 0 ; c < colDefn.length ; c++) {
			var cls = 'ptcol-' + colDefn[c].key;
			if (!colDefn[c].nosort) {
				if (sortCol < 0) { //init
					sortCol = c;
					cls += ' headerSortUp';
				}
				cls += ' header" onClick="return headerClick(event, ' + c + ');';
			}
			th += '<th class="' + cls + '">' + colDefn[c].label + '</th>';
		}
	$('#results-table').append(th + '</tr></thead>');


	if (howMany > searchResults.length) howMany = searchResults.length;

	for (var i = 0 ; i < howMany ; i++) {
		var r = '<tr onClick="return rowClick(this);" class="clickable pageableTable-visible">';
		for (var c = 0 ; c < colDefn.length ; c++) {
			r += '<td class="ptcol-' + colDefn[c].key + '"></td>';
		}
		r += '</tr>';
		$('#results-table').append(r);
	}

	sTable.initSort();
	sTable.initValues();


	newSlice(sortCol, sortReverse);

	$('#progress').hide();
	sTable.sliderInit();
	show();

	$('#results-table').on('mousewheel', function(ev) {  //firefox? DOMMouseScroll
		if (!sTable.opts.sliderElement) return;
		ev.preventDefault();
		var delta = Math.max(-1, Math.min(1, (event.wheelDelta || -event.detail)));
		if (delta != 0) nudge(-delta);
	});

}

function rowClick(el) {
	console.log(el);
	var mid = el.getAttribute('data-id');
	browse(mid);
	return false;
}

function headerClick(ev, c) {
	start = 0;
	ev.preventDefault();
	console.log(c);
	if (sortCol == c) {
		sortReverse = !sortReverse;
	} else {
		sortReverse = false;
	}
	sortCol = c;

	$('#results-table th.headerSortDown').removeClass('headerSortDown');
	$('#results-table th.headerSortUp').removeClass('headerSortUp');
	if (sortReverse) {
		$('#results-table th.ptcol-' + colDefn[c].key).addClass('headerSortUp');
	} else {
		$('#results-table th.ptcol-' + colDefn[c].key).addClass('headerSortDown');
	}
console.log('sortCol=%d sortReverse=%o', sortCol, sortReverse);
	newSlice(sortCol, sortReverse);
	show();
}


function show() {
	$('#results-table td').html('');
	$('#results-table tbody tr').show();
	for (var i = 0 ; i < results.length ; i++) {
		//$('#results-table tbody tr')[i].title = 'Encounter ' + searchResults[results[i]].id;
		$('#results-table tbody tr')[i].setAttribute('data-id', searchResults[results[i]].individualID);
		for (var c = 0 ; c < colDefn.length ; c++) {
			$('#results-table tbody tr')[i].children[c].innerHTML = '<div>' + sTable.values[results[i]][c] + '</div>';
		}
	}
	if (results.length < howMany) {
		$('#results-slider').hide();
		for (var i = 0 ; i < (howMany - results.length) ; i++) {
			$('#results-table tbody tr')[i + results.length].style.display = 'none';
		}
	} else {
		$('#results-slider').show();
	}

	//if (sTable.opts.sliderElement) sTable.opts.sliderElement.slider('option', 'value', 100 - (start / (searchResults.length - howMany)) * 100);
	sTable.sliderSet(100 - (start / (sTable.matchesFilter.length - howMany)) * 100);
	displayPagePosition();
}

function xshow() {
	$('#results-table td').html('');
	for (var i = 0 ; i < results.length ; i++) {
		//$('#results-table tbody tr')[i].title = searchResults[results[i]].individualID;
		$('#results-table tbody tr')[i].setAttribute('data-id', searchResults[results[i]].get('id'));
		for (var c = 0 ; c < colDefn.length ; c++) {
			$('#results-table tbody tr')[i].children[c].innerHTML = sTable.values[results[i]][c];
			$('#results-table tbody tr')[i].children[c].innerHTML = sTable.values[results[i]][c];
		}
	}

	//sTable.sliderSet(100 - (start / (searchResults.length - howMany)) * 100);
	sTable.sliderSet(100 - (start / (sTable.matchesFilter.length - howMany)) * 100);
}

function newSlice(col, reverse) {
	results = sTable.slice(col, start, start + howMany, reverse);
}


function computeCounts() {
	counts.total = sTable.matchesFilter.length;
	return;  //none of the below applies here! (cruft from encounters for prosperity)
	counts.unid = 0;
	counts.ided = 0;
	counts.dailydup = 0;
	var uniq = {};

	for (var i = 0 ; i < counts.total ; i++) {
		console.log('>>>>> what up? %o', searchResults[sTable.matchesFilter[i]]);
		var iid = searchResults[sTable.matchesFilter[i]].individualID;
		if (iid == 'Unassigned') {
			counts.unid++;
		} else {
			var k = iid + ':' + searchResults[sTable.matchesFilter[i]].get('year') + ':' + searchResults[sTable.matchesFilter[i]].get('month') + ':' + searchResults[sTable.matchesFilter[i]].get('day');
			if (!uniq[k]) {
				uniq[k] = true;
				counts.ided++;
			} else {
				counts.dailydup++;
			}
		}
	}
/*
	var k = Object.keys(uniq);
	counts.ided = k.length;
*/
}


function displayCounts() {
	for (var w in counts) {
		$('#count-' + w).html(counts[w]);
	}
}


function displayPagePosition() {
	if (sTable.matchesFilter.length < 1) {
		$('#table-info').html('<b>no matches found</b>');
		return;
	}

	var max = start + howMany;
	if (sTable.matchesFilter.length < max) max = sTable.matchesFilter.length;
	$('#table-info').html((start+1) + ' - ' + max + ' of ' + sTable.matchesFilter.length);
}


function applyFilter() {
	var t = $('#filter-text').val();
console.log(t);
	sTable.filter(t);
	start = 0;
	newSlice(1);
	show();
	computeCounts();
	displayCounts();
}


function nudge(n) {
	start += n;
	if ((start + howMany) > sTable.matchesFilter.length) start = sTable.matchesFilter.length - howMany;
	if (start < 0) start = 0;
console.log('start -> %d', start);
	newSlice(sortCol, sortReverse);
	show();
}

function tableDn() {
	return nudge(-1);
	start--;
	if (start < 0) start = 0;
	newSlice(sortCol, sortReverse);
	show();
}

function tableUp() {
	return nudge(1);
	start++;
	//if (start > searchResults.length - 1) start = searchResults.length - 1;
	if (start > sTable.matchesFilter.length - 1) start = sTable.matchesFilter.length - 1;
	newSlice(sortCol, sortReverse);
	show();
}






function _colStatus(o) {
	var s = o.get('status');
	if (!s) return 'new';
	return s;
}

function _colStatusSort(o) {
	var s = o.get('status');
	if (!s) return 0;
	if (s == 'active') return 1;
	return 2;
}




function _colIndividual(o) {
	//var i = '<b><a target="_new" href="individuals.jsp?number=' + o.individualID + '">' + o.individualID + '</a></b> ';
	var i = '<b>' + o.individualID + '</b> ';
	if (!extra[o.individualID]) return i;
	i += (extra[o.individualID].firstIdent || '') + ' <i>';
	i += (extra[o.individualID].genusSpecies || '') + '</i>';
	return i;
}


function _colNumberEncounters(o) {
	if (!extra[o.individualID]) return '';
	var n = extra[o.individualID].numberEncounters;
	if (n == undefined) return '';
	return n;
}

/*
function _colYearsBetween(o) {
	return o.get('maxYearsBetweenResightings');
}
*/

function _colNumberLocations(o) {
	if (!extra[o.individualID]) return '';
	var n = extra[o.individualID].locations;
	if (n == undefined) return '';
	return n;
}


function _colTaxonomy(o) {
	if (!o.get('genus') || !o.get('specificEpithet')) return 'n/a';
console.log('obj %o', o);
console.log('obj %o', o);
console.log('obj %o', o);
console.log('obj %o', o);
console.log('obj %o', o);
console.log('obj %o', o);
	return o.get('genus') + ' ' + o.get('specificEpithet');
}


function _colRowNum(o) {
	return o._rowNum;
}


function _colThumb(o) {
	if (!extra[o.individualID]) return '';
	var url = extra[o.individualID].thumbUrl;
	if (!url) return '';
	return '<div style="background-image: url(' + url + ');"><img src="' + url + '" /></div>';
}



function _textExtraction(n) {
	var s = $(n).text();
	var skip = new RegExp('^(none|unassigned|)$', 'i');
	if (skip.test(s)) return 'zzzzz';
	return s;
}





function _colDataTypes(o) {
	var dt = '';
	if (o.get('hasImages')) dt += '<img title="images" src="images/Crystal_Clear_filesystem_folder_image.png" />';
	if (o.get('hasTissueSamples')) dt += '<img title="tissue samples" src="images/microscope.gif" />';
	if (o.get('hasMeasurements')) dt += '<img title="measurements" src="images/ruler.png" />';
	return dt;
}

function _colDataTypesSort(o) {
	var dt = '';
	if (o.get('hasImages')) dt += ' images';
	if (o.get('hasTissueSamples')) dt += ' tissues';
	if (o.get('hasMeasurements')) dt += ' measurements';
	return dt;
}


function _colTimeSubmitted(o) {
	var t = o.get('timeSubmitted');
	if (!t || (t < 1)) return '';
	var d = new Date();
	d.setTime(t);
	return d.toLocaleString();
}

function _colDate(o) {
	var t = o.get('startTime');
	if (!t || (t < 1)) return '';
	var d = new Date();
	d.setTime(t);
	return d.toLocaleString();
}


function _colDateSort(o) {
	var t = o.get('startTime');
	if (!t || (t < 1)) return 0;
	return t - 0;
}

function _colSubmitter(o) {
	var n = o.get('username');
	if (n) return n;
	var e = o.get('email');
	n = o.get('name') || '';
	if (e) n += ' (' + e + ')';
	return n;
}

function _numImages(o) {
	var m = o.get('media');
	if (!m) return 0;
	return m.length;
}


function _colOcc(o) {
	var occ = o.get('occurrences');
	if (!occ || (occ.length < 1)) return '';
	return occ.join(', ');
}


function _colRowNum(o) {
	return o._rowNum;
}


function _colThumb(o) {
	var url = o.thumbUrl();
	if (!url) return '';
	return '<div style="background-image: url(' + url + ');"><img src="' + url + '" /></div>';
	return '<div style="background-image: url(' + url + ');"></div>';
	return '<img src="' + url + '" />';
}


function _colModified(o) {
	var m = o.get('modified');
	if (!m) return '';
	var d = wildbook.parseDate(m);
	if (!wildbook.isValidDate(d)) return '';
	return d.toISOString().substring(0,10);
}

function _colCreationDate(o) {
	var m = o.get('dwcDateAdded');
	if (!m) return '';
	var d = wildbook.parseDate(m);
	if (!wildbook.isValidDate(d)) return '';
	return d.toISOString().substring(0,10);
}



function _textExtraction(n) {
	var s = $(n).text();
	var skip = new RegExp('^(none|unassigned|)$', 'i');
	if (skip.test(s)) return 'zzzzz';
	return s;
}


function cleanValue(obj, colnum) {
	var v = obj.get(colDefn[colnum].key);
	var empty = /^(null|unknown|none|undefined)$/i;
	if (empty.test(v)) v = '';
	return v;
}


function dataTypes(obj, fieldName) {
	var dt = [];
	_.each(['measurements', 'images'], function(w) {
		if (obj[w] && obj[w].models && (obj[w].models.length > 0)) dt.push(w.substring(0,1));
	});
	return dt.join(', ');
}

</script>



<script type="text/javascript">



var allMS;
var searchResults;

$(document).ready( function() {
	wildbook.init( function() {
		allMS = new wildbook.Collection.MediaSubmissions();
		allMS.fetch({
			url: '/test/obj/mediasubmission/get/status/*',  //override and only fill collection with null-status
			success: function() {
				$('#admin-div').show();
				searchResults = allMS.models;
				doTable();
			}
		});
	});
});



var mediaSubmission;

var allEncounters = false;

function updateEncounters(callback) {

	if (!allEncounters) allEncounters = new wildbook.Collection.Encounters();
	allEncounters.fetch({
		success: function() { callback(); }
	});
}




function browse(msID) {
	msID -= 0;
	console.log(msID);
/*
	mediaSubmission = allMS.findWhere({id: msID});
	if (!mediaSubmission) {
		alert('could not find MediaSubmission with id=' + msID);
		return false;
	}
	displayMS(mediaSubmission);
*/
	mediaSubmission = new wildbook.Model.MediaSubmission({id: msID});
	mediaSubmission.fetch({
		url: '/test/obj/mediasubmission/get/id/' + msID,
		success: function(d) {
			updateEncounters( function() {
				displayMS();
			});
		},
		error: function(a,b,c) { msError(a,b,c); }
	});
}

function displayMS(d) {
console.log('success %o', d);
	var m = mediaSubmission.get('media');
console.log(m);
	if (!m || (m.length < 1)) {
		alert('no images for this. :(');
		return false;
	}

	$('#admin-div').hide();
	var h = '';
	for (var i = 0 ; i < m.length ; i++) {
		var mObj = new wildbook.Model.SinglePhotoVideo(m[i]);
		var encs = encountersForImage(mObj.id);
		var note = '';
		if (encs) {
			var list = '<div class="enc-list">';
			for (var e in encs) {
				list += '<div><a target="_new" href="encounters/encounter.jsp?number=' + encs[e].id + '">' + encs[e].id + '</a></div>';
			}
			list += '</div>';
			note = '<div class="note" onClick="return noteClick(event);">' + encs.length + list + '</div>';
		}
		var info = '<div class="image-info">3/11 08:21:04</div>';
		h += '<div id="' + mObj.id + '" class="image"><img class="thumb" src="' + mObj.url() + '" />' + note + info + '</div>';
	}
	$('#images-unused').html(h);
	$('.image').click( function(ev) {
		$('.note .enc-list').hide();
		ev.preventDefault();
		toggleImage(ev.currentTarget.id);
	});

	$('#work-div').show();
	updateCounts();

	$('#enc-submitterID').val(mediaSubmission.get('username'));
	$('#enc-submitterEmail').val(mediaSubmission.get('email'));
	$('#enc-verbatimLocality').val(mediaSubmission.get('verbatimLocation'));
	$('#enc-dateInMilliseconds').val(mediaSubmission.get('startTime'));
	$('#enc-dateInMilliseconds-human').html(_colDate(mediaSubmission));
	$('#enc-decimalLatitude').val(mediaSubmission.get('latitude'));
	$('#enc-decimalLongitude').val(mediaSubmission.get('longitude'));
}


function noteClick(ev) {
	ev.stopPropagation();
	var el = $(ev.target);
	if (!el.hasClass('note')) {
		return true;
	}
	ev.preventDefault();
	$('.note .enc-list').hide();
	el.find('.enc-list').show();
	return false;
}


function msError(a,b,c) {
	console.error('error %o %o %o', a,b,c);
	$('#admin-div').html('<h1 class="error">error, probably bad id</h1>');
}

function updateCounts() {
	$('#count-total').html('total images: <b>' + mediaSubmission.get('media').length + '</b>');
	$('#count-used').html('images in encounter: <b>' + $('.used').length + '</b>');
}

function toggleImage(iid) {
	var d = $('#' + iid);
	if (d.hasClass('used')) {
		d.removeClass('used');
		d.appendTo($('#images-unused'));
	} else {
		d.addClass('used');
		d.appendTo($('#images-used'));
	}
	updateCounts();
console.log(iid);
}


var encounter;
function createEncounter() {
	var imgs = $('.used');
	if (imgs.length < 1) return alert('no images attached to this encounter');

	$('#enc-create-button').hide();
	var eid = wildbook.uuid();
	encounter = new wildbook.Model.Encounter({catalogNumber: eid});
	var props = ['submitterID', 'submitterEmail', 'verbatimLocality', 'individualID', 'dateInMilliseconds', 'decimalLatitude', 'decimalLongitude'];
	for (var i in props) {
		var val = $('#enc-' + props[i]).val();
		if (val == '') val = null;
		if ((i == 3) && (val == null)) val = 0;
		encounter.set(props[i], val);
	}

	//always do these
	delete(encounter.attributes.sex);  //temporary hack cuz of my testing environment permissions
	encounter.set('approved', true);
	encounter.set('state', 'approved');

	var iarr = [];
	for (var i = 0 ; i < imgs.length ; i++) {
		iarr.push({ class: 'org.ecocean.SinglePhotoVideo', dataCollectionEventID: imgs[i].id });
	}
	encounter.set('images', iarr);
console.log(iarr);

	encounter.save({}, {
		error: function(a,b,c) { console.error('error saving new encounter: %o %o %o', a,b,c); },
		success: function(d) {
			updateMediaSubmissionStatus('active');
			$('#enc-results').html('created <a target="_new" href="encounters/encounter.jsp?number=' + eid + '">' + eid + '</a>');
			$('#images-used').html('');

			updateEncounters(function() {
				displayMS();
				$('#enc-create-button').show();
			});
		}
	});
}

function encountersForImage(imgID) {
	var e = [];
	if (!allEncounters || (allEncounters.models.length < 1)) return false;
	for (var i in allEncounters.models) {
		var imgs = allEncounters.models[i].get('images');
		if (!imgs || (imgs.length < 1)) continue;
		for (var j in imgs) {
			if (imgs[j].id == imgID) e.push(allEncounters.models[i]);
		}
	}
	if (e.length < 1) return false;
	return e;
}


function closeMediaSubmission() {
	updateMediaSubmissionStatus('closed');
	window.location.reload();
}


function updateMediaSubmissionStatus(s) {
	if (!mediaSubmission) return;
	var tmp = $.extend({}, mediaSubmission.attributes);
	delete(tmp.media);  //TODO fix rest???
	tmp.status = s;
	$.post('obj/mediasubmission/save', tmp, function() { console.info('updated mediaSubmission (id=%d) to %s', tmp.id, s); });
}


</script>


<div id="admin-div">
<h1>MediaSubmission review</h1>

<p>
<input placeholder="filter by text" id="filter-text" onChange="return applyFilter()" />
<input type="button" value="filter" />
<input type="button" value="clear" onClick="$('#filter-text').val(''); applyFilter(); return true;" />
<span style="margin-left: 40px; color: #888; font-size: 0.8em;" id="table-info"></span>
</p>

<div class="pageableTable-wrapper">
	<div id="progress">Generating encounters table</div>
	<table id="results-table"></table>
	<div id="results-slider"></div>
</div>

</div>



<div id="work-div">
	<p><b>Images submitted by user.</b> (Click to add to Encounter below.)</p>
	<div id="images-unused"></div>

<div id="encounter-div">
	<h1>Encounter to create</h1>

	<div id="images-used"></div>

	<div style="padding: 5px;">
		<span id="count-total"></span>
		<span id="count-used"></span>
	</div>

	<div id="enc-form">
		<div><label for="enc-submitterID">Submitter User</label><input id="enc-submitterID" /></div>
		<div><label for="enc-submitterEmail">Submitter Email</label><input id="enc-submitterEmail" /></div>
		<div><label for="enc-verbatimLocality">Verbatim Location</label><input id="enc-verbatimLocality" /></div>
		<div><label for="enc-individualID">Individual ID</label><input id="enc-individualID" /></div>
		<div><label for="enc-dateInMilliseconds">(start) date/time</label><input id="enc-dateInMilliseconds" /> <span id="enc-dateInMilliseconds-human"></span></div>
		<div><label for="enc-decimalLatitude">Latitude</label><input id="enc-decimalLatitude" />
		&nbsp; <label for="enc-decimalLongitude">Longitude</label><input id="enc-decimalLongitude" /></div>
		<div><label for="enc-researcherComment">Comment</label><textarea id="enc-dateInMilliseconds">Created from MediaSubmission</textarea></div>
	</div>

<div style="margin: 10px;">
	<input type="button" id="enc-create-button" value="create encounter" onClick="createEncounter()" />
	<input type="button" value="close this MediaSubmission" onClick="closeMediaSubmission()" />
	<input type="button" value="cancel" onClick="window.location.reload()" />
</div>

	<div id="enc-results"></div>

</div>
</div>

<jsp:include page="footerfull.jsp" flush="true"/>
