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

const fadeOutIn = [
  { opacity: 1 },
  { opacity: 0 },
  { opacity: 1 },
];

const fadeTiming = {
  duration: 1000,
  iterations: 1,
};

function trocaOrdem() {
  const epListContainer = document.getElementById('episode-list');
  const epList = document.querySelectorAll(".reversible");
  const arrowUp = document.getElementById("library-arrow-up");
  const arrowDown = document.getElementById("library-arrow-down");
  epListContainer.classList.toggle('my100');
  arrowUp.classList.toggle('hidden');
  arrowDown.classList.toggle('hidden');
  epList.forEach(function(list){
    list.animate(fadeOutIn, fadeTiming);
    setTimeout(() => {
      list.classList.toggle('flex-column');
      list.classList.toggle('flex-column-reverse');
    }, 500);
    setTimeout(() => {
      epListContainer.classList.toggle('my100');
    }, 500);
  });
}
