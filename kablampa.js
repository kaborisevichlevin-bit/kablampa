/*
 * KABLampa — автоподключение расширений.
 * Выполняется ДО загрузки Lampa и добавляет в список расширений всё,
 * чего там ещё нет. Расширение, которое вы удалили вручную, повторно
 * не добавляется (запоминается в kablampa_seeded).
 * Чтобы добавить новое расширение в сборку — допишите его в PLUGINS.
 */
(function () {
    'use strict';

    var PLUGINS = [
        // Основа
        { name: 'TMDB Proxy',               url: 'https://cub.best/plugin/tmdb-proxy' },
        { name: 'Showy Pro',                url: 'http://showy.online/m.js' },
        // Подборки и вкладки
        { name: 'Коллекции CUB',            url: 'https://cub.best/plugin/collections' },
        { name: 'Дополнительные категории', url: 'https://lampame.github.io/main/newcategory.js' },
        { name: 'Кинопоиск: Буду смотреть', url: 'https://and7ey.github.io/lampa/kinopoisk.js' },
        // Интерфейс
        { name: 'Рейтинги КП и IMDb',       url: 'https://nb557.github.io/plugins/rating.js' },
        { name: 'Интерфейс мод',            url: 'https://lampaplugins.github.io/store/interface_mod.js' },
        { name: 'Логотипы вместо названий', url: 'https://lampaplugins.github.io/store/logo.js' },
        { name: 'Трейлеры iTunes',          url: 'https://plugin.rootu.top/trailers.js' },
        { name: 'Пункт «Выход» в меню',     url: 'https://tsynik.github.io/lampa/e.js' },
        // Сериалы, история, оформление
        { name: 'Статус сериалов',          url: 'https://igorek1986.github.io/lampa-plugins/status.js' },
        { name: 'MyShows: просмотренные серии', url: 'https://igorek1986.github.io/lampa-plugins/myshows.js' },
        { name: 'Trakt: история просмотров', url: 'https://lampame.github.io/main/trakttv.js' },
        { name: 'Full Hero: карточка в стиле Apple TV', url: 'https://igorek1986.github.io/lampa-plugins/full_hero.js' }
    ];

    function read(key, def) {
        try {
            var v = window.localStorage.getItem(key);
            return v ? JSON.parse(v) : def;
        } catch (e) {
            return def;
        }
    }

    try {
        var seeded  = read('kablampa_seeded', []);
        var plugins = read('plugins', []).map(function (p) {
            return typeof p == 'string' ? { url: p, status: 1 } : p;
        });
        var have = plugins.map(function (p) { return p.url; });
        var changed = false;

        PLUGINS.forEach(function (p) {
            if (seeded.indexOf(p.url) >= 0) return;
            seeded.push(p.url);
            if (have.indexOf(p.url) < 0) {
                plugins.push({ url: p.url, status: 1, name: p.name, author: 'KABLampa' });
            }
            changed = true;
        });

        if (changed) {
            window.localStorage.setItem('plugins', JSON.stringify(plugins));
            window.localStorage.setItem('kablampa_seeded', JSON.stringify(seeded));
            console.log('KABLampa', 'plugins seeded:', plugins);
        }
    } catch (e) {
        console.warn('KABLampa', 'seed error:', e && e.message);
    }
})();
