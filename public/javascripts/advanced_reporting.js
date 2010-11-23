$(function() {
	$('table.show_data td').click(function() {
		$('table.show_data td').not(this).removeClass('selected');
		$(this).addClass('selected');
		var id = 'div#' + $(this).attr('id') + '_data';
		$('div.advanced_reporting_data').not($(id)).hide();
		$(id).show();
	});
	$('table.tablesorter').tablesorter();
	$('table.tablesorter').bind("sortEnd", function() {
		var section = $(this).parent().attr('id');
		var even = true;
		$.each($('div#' + section + ' table tr'), function(i, j) {
			$(j).removeClass('even').removeClass('odd');
			$(j).addClass(even ? 'even' : 'odd');
			even = !even;
		});
	});
	if($('input#product_id').length > 0) {
		$('select#advanced_reporting_product_id').val($('input#product_id').val());
	}
	if($('input#taxon_id').length > 0) {
		$('select#advanced_reporting_taxon_id').val($('input#taxon_id').val());
	}
})
