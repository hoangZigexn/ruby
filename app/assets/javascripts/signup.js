// Signup page JavaScript functionality
document.addEventListener('DOMContentLoaded', function() {
  // Fade in animation
  var observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, observerOptions);

  // Observe all fade-in elements
  document.querySelectorAll('.fade-in').forEach(function(el) {
    observer.observe(el);
  });
  
  // Password confirmation validation
  var password = document.getElementById('password');
  var confirmPassword = document.getElementById('confirmPassword');
  
  function validatePassword() {
    if (password.value !== confirmPassword.value) {
      confirmPassword.setCustomValidity('Passwords do not match');
    } else {
      confirmPassword.setCustomValidity('');
    }
  }
  
  if (password && confirmPassword) {
    password.addEventListener('change', validatePassword);
    confirmPassword.addEventListener('keyup', validatePassword);
  }
});
