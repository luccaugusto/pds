function init()
{
	var observer0 = new IntersectionObserver(function(entries) {
		// isIntersecting is true when element and viewport are overlapping
		// isIntersecting is false when element and viewport don't overlap
		if(entries[0].isIntersecting) {
			document.getElementsByClassName('bg')[0].style.backgroundColor = "#ffce44";
		}
	}, { threshold: [0.5] });

	var observer1 = new IntersectionObserver(function(entries) {
		// isIntersecting is true when element and viewport are overlapping
		// isIntersecting is false when element and viewport don't overlap
		if(entries[0].isIntersecting) {
			document.getElementsByClassName('bg')[0].style.backgroundColor = "black";
		}
	}, { threshold: [0.5] });

	console.log(document.getElementById("temporada-0"));

	observer0.observe(document.getElementById("temporada-0"));
	observer1.observe(document.getElementById("temporada-1"));
}

window.onload = init;
