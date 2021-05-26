import ddz from 'ic:canisters/ddz';

ddz.greet(window.prompt("Enter your name:")).then(greeting => {
  window.alert(greeting);
});
