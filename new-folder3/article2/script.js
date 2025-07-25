const slider = document.querySelector('.image-slider');
const images = slider.querySelectorAll('img');
let currentIndex = 0;

function showImage(index) {
  images.forEach(img => img.style.display = 'none');
  images[index].style.display = 'block';
}

function nextImage() {
  currentIndex = (currentIndex + 1) % images.length;
  showImage(currentIndex);
}

setInterval(nextImage, 5000); // Change image every 5 seconds
