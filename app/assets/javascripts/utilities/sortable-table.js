//= require @shopify/draggable/lib/sortable.js

const targets = document.querySelectorAll('.sortable-table');

targets.forEach(function(target) {
	if (testTargetForSortableInteraction(target)) {
		new Sortable.default(target.querySelector('tbody'), {
			draggable: 'tr'
		}).on('sortable:stop', function() {
			var sortableIDs = [];
			window.setTimeout(function() { // Sometimes the proxy objects still exist in the DOM.
				target.querySelectorAll('tbody tr').forEach(function(child) {
					sortableIDs.push(child.getAttribute('data-elementid'));
				});
				fetch(target.getAttribute('data-apipoint') + '/reorder', {
					method: 'POST',
					cache: 'no-cache',
					headers: {
						'Content-Type': 'application/json'
					},
					body: JSON.stringify({ids: sortableIDs})
				  }).then(function(response) {
					  console.log(response);
				  });
			}, 500);
		});
	}
});

function testTargetForSortableInteraction(el) {
	var status = el.hasAttribute('data-apipoint');

	el.querySelectorAll('tbody tr').forEach(function(child) {
		status = status && child.hasAttribute('data-elementid');
	});

	return status;
}
