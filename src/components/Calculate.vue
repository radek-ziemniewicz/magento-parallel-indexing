<template>
  <main>
    <div class="docs">
      <h1><strong>Disclaimer</strong></h1>
      <p>
        Parallel indexing creates several tables to be used in parallel, in some cases this might causes some side
        effects such as slowness on DB, that said, we don’t suggest this for merchants with small catalog.
      </p>
      <p>
        In general, if the full reindex takes over 30 min, then parallel indexing should be something to consider.
      </p>
      <p>
        Just keep in mind that  reindexing is considered a bad practice when performed manually in production, the cron
        should be enabled and running a complementary indexing each minute.
      </p>
      <p>
        Magento indexer threads counter based on:<br>
        <a href="https://devdocs.magento.com/guides/v2.2/config-guide/cli/config-cli-subcommands-index.html#config-cli-subcommands-index-reindex-parallel"
          target="_blank">
          https://devdocs.magento.com/guides/v2.2/config-guide/cli/config-cli-subcommands-index.html#config-cli-subcommands-index-reindex-parallel
        </a><br>
        <a href="https://community.magento.com/t5/Magento-DevBlog/Indexers-parallelization-and-optimization/ba-p/104922"
           target="_blank">
          https://community.magento.com/t5/Magento-DevBlog/Indexers-parallelization-and-optimization/ba-p/104922
        </a>
      </p>
    </div>
    <div class="input">
      <label for="websites">Websites</label>
      <input id="websites" name="websites" type="number" min="1" v-model="websites"/>
      <p class="info font-mono">$ bin/magento store:website:list</p>
    </div>
    <div class="input">
      <label for="customerGroups">Customer groups</label>
      <input id="customerGroups" name="customerGroups" type="number" min="1" v-model="customerGroups"/>
      <p class="info font-mono">SELECT count(*)-1 FROM customer_group;</p>
    </div>
    <div class="input">
      <label for="threads">
        Your current number of threads
        <span class="cursor-pointer" title="For processors with Hyper-Threading Technology, 1 core has 2 threads">ℹ</span>
      </label>
      <input id="threads" name="threads" type="number" min="1" v-model="threads"/>
      <p class="info font-mono">$ nproc</p>
    </div>
    <div class="code" v-if="result">
      <div class="step">
        <p>
          First, set the dimension mode:
        </p>
        <pre>
          $ bin/magento indexer:set-dimensions-mode catalog_product_price website
        </pre>
      </div>
      <div class="step">
        <p>
          For cloud based instances, set the env variable in the <b>.magento.env.yaml</b> file or In cloud UI:
        </p>
        <pre>
          $ MAGE_INDEXER_THREADS_COUNT={{ result }}
        </pre>
        <p>
          If using in staging or integration environment:
        </p>
        <pre>
          $ bin/magento index:reindex
        </pre>
        <p>
          If using in production, stop the cron first and then reset and reindex index by index:
        </p>
        <pre>
          $ php vendor/bin/ece-tools cron:disable; php vendor/bin/ece-tools cron:kill; php vendor/bin/ece-tools cron:unlock; php bin/magento indexer:info | awk ‘{print $1}’ | xargs -I {} bash -c ‘php bin/magento indexer:reset {} && php bin/magento indexer:reindex {}’; php vendor/bin/ece-tools cron:enable
        </pre>
      </div>
      <div class="step">
        <p>
          For on premises instances, set the env variable in <b>app/etc/env.php</b> files:
        </p>
        <pre>
          $ MAGE_INDEXER_THREADS_COUNT={{ result }}
          $ bin/magento index:reindex
        </pre>
        <p>
          <b>Important: If using in production, stop the cron first!</b>
        </p>
      </div>
      <div class="step note">
        <p>
          Just for testing purposes, you can use parallel indexing only once, see the example below:
        </p>
        <pre>
          $ bin/magento indexer:set-dimensions-mode catalog_product_price website
          $ bin/magento indexer:reset catalogsearch_fulltext
          $ php -d memory_limit=-1 MAGE_INDEXER_THREADS_COUNT={{ result }} -f bin/magento indexer:reindex catalogsearch_fulltext
          $ bin/magento indexer:set-dimensions-mode none
        </pre>
      </div>
    </div>
    <div v-else class="message">
      <p>
        You can't use the parallel indexer, because the number of websites times the number of customer groups is greater than the number of threads.<br>
        Required number of threads: {{ this.websites * this.customerGroups }}.
      </p>
    </div>
  </main>
</template>

<script>
export default {
  name: 'Calculate',
  data () {
    return {
      websites: 2,
      customerGroups: 1,
      threads: 4
    };
  },
  computed: {
    result () {
      return this.websites * this.customerGroups <= this.threads ? this.websites * this.customerGroups : 0;
    }
  }
}
</script>

<style>
  a:link, a:visited {
    @apply text-blue-700;
  }
  main {
    @apply w-full;
  }
  div.input {
    @apply w-full py-2 md:flex;
  }
  div.input label {
    @apply block w-full text-left px-2 py-2 border border-white md:w-1/3 md:text-right;
  }
  div.input input {
    @apply block border border-black rounded px-3 py-2 mx-2;
  }
  div.input p.info {
    @apply block bg-blue-100 py-2 px-4 mx-2 mt-2 rounded border border-blue-300 md:mt-0 overflow-x-scroll whitespace-nowrap;
  }
  div.docs {
    @apply border-black rounded border px-5 py-4 m-2 mb-10 bg-gray-100 border-dashed;
  }
  div.docs p {
    @apply py-1;
  }
  div.code {
    @apply my-10;
  }
  div.code div.step {
    @apply bg-yellow-200 overflow-x-scroll py-6 mb-2;
  }
  div.code div.step p {
    @apply ml-20;
  }
  div.code div.step pre {
    @apply pt-4 pb-0 mb-0;
  }
  div.code div.step p, div.code div.step pre {
    @apply px-2;
  }
  div.code div.note {
    @apply bg-gray-200;
  }
  div.message {
    @apply bg-red-100 px-10 py-8 text-center mt-10;
  }
</style>