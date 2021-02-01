function initActivateTargets() {
	const targets = document.querySelectorAll('.active-inactive-toggle');

	targets.forEach(function(el) {
		if (!testTargetForActiveInactiveInteraction(el)) { return; }
			const activeIcon = el.hasAttribute('data-activeicon') ? el.getAttribute('data-activeicon'): 'bi-star-fill';
			const inactiveIcon = el.hasAttribute('data-inactiveicon') ? el.getAttribute('data-inactiveicon'): 'bi-star';

			el.addEventListener('click', function(e) {
				e.preventDefault();
				var response = fetch(el.getAttribute('data-apipoint') + '/' + el.getAttribute('data-elementid') + '/toggle_active', {
					method: 'PATCH',
					cache: 'no-cache',
				}).then(response => response.json())
				.then(data => {
					if (data.active) {
						el.classList.remove(inactiveIcon);
						el.classList.add(activeIcon);
					} else {
						el.classList.remove(activeIcon);
						el.classList.add(inactiveIcon);
					}
				})
				.catch((error) => {
				  console.error('Error:', error);
				});
				
			});
	});


	function testTargetForActiveInactiveInteraction(el) {
		var status = el.hasAttribute('data-apipoint') && el.hasAttribute('data-elementid');

		return status;
	}
}

initActivateTargets();