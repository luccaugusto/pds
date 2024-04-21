function maisDetalhes(div_id) {
	const div = document.getElementById("div-ep-"+div_id);
  const label = document.getElementById("mostrar-detalhes-ep-"+div_id);

	if (div.style.display === 'none') {
		div.style.display = 'block';
		label.textContent='Esconder Detalhes';
	}else{
		div.style.display = 'none';
		label.textContent='Mostrar Detalhes';
	}
}

function mostrarTemporada(div_id) {
	const div = document.getElementById(div_id);

	if (div.style.display === 'none') {
		div.style.display = 'block';
	}else{
		div.style.display = 'none';
	}
}

function trocaOrdem() {
  const epList = document.querySelectorAll(".reversible");
  const arrowUp = document.getElementById("library-arrow-up");
  const arrowDown = document.getElementById("library-arrow-down");
  arrowUp.classList.toggle('hidden');
  arrowDown.classList.toggle('hidden');
  epList.forEach(function(ep){
    ep.classList.toggle('flex-column');
    ep.classList.toggle('flex-column-reverse');
  });
}
