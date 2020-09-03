function maisDetalhes(div_id) {
	var div = document.getElementById("div-"+div_id);
	var label = document.getElementById("span-"+div_id);

	if (div.style.display === 'none') {
		div.style.display = 'block';
		label.innerhtml='esconder';
	}else{
		div.style.display = 'none';
		label.innerhtml='mostrar detalhes';
	}
}

function mostrarTemporada(div_id) {
	var div = document.getElementById(div_id);

	if (div.style.display === 'none') {
		div.style.display = 'block';
	}else{
		div.style.display = 'none';
	}
}
