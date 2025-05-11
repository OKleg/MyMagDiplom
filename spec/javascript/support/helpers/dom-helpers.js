const fakeDOMContentLoaded = () => {
  window.document.dispatchEvent(
    new Event("DOMContentLoaded", {
      bubbles: true,
      cancelable: true,
    })
  );
};

const mountHead = () => {
  var link = document.createElement("link");
  link.rel = "stylesheet";
  link.type = "text/css";
  link.href = "https://unpkg.com/trix@2.0.8/dist/trix.css";
  document.head.appendChild(link);

  var script = document.createElement("script");
  script.type = "text/javascript";
  script.src = "https://unpkg.com/trix@2.0.8/dist/trix.umd.min.js";
  document.head.appendChild(script);
};

const mountDOM = (htmlString = "") => {
  const div = document.createElement("div");
  div.id = "mountedHtmlWrapper";
  div.innerHTML = htmlString;
  document.body.appendChild(div);

  fakeDOMContentLoaded();

  return div;
};

const cleanupDOM = () => {
  document.body.innerHTML = "";
};

export { cleanupDOM, mountDOM, mountHead };
