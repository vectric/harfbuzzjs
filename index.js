import hbjs from './hbjs.js';
import hb from './hb.js';

const promise = new Promise(function (resolve, reject) {
  hb().then((instance) => {
    resolve(hbjs(instance));
  }, reject);
});

export default promise;
