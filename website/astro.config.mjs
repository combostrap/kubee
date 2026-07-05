// @ts-check
import {defineConfig} from 'astro/config';
import starlight from '@astrojs/starlight';
import rehypeHrefRewrite from "./src/unified/rehype-href-rewrite.js";
// https://astro.build/config
export default defineConfig({
    // never allows relative link
    trailingSlash: 'never',
    integrations: [
        starlight({
            title: 'Kubee',
            social: [{icon: 'github', label: 'GitHub', href: 'https://github.com/combostrap/kubee'}],
            // sidebar: [
            // 	{
            // 		label: 'Guides',
            // 		items: [
            // 			// Each item here is one entry in the navigation menu.
            // 			{ label: 'Example Guide', slug: 'guides/example' },
            // 		],
            // 	},
            // 	{
            // 		label: 'Reference',
            // 		autogenerate: { directory: 'reference' },
            // 	},
            // ],
        }),
    ],
    markdown: {
        rehypePlugins: [
            rehypeHrefRewrite
        ]
    },

});
