import hbjs from './hbjs.js';
import hb from './dist/hb.js';

const promise = new Promise(function (resolve, reject) {
  hb().then((instance) => {
    resolve(hbjs(instance));
  }, reject);
});

export default promise;
