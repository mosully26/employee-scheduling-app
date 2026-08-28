<script lang="ts">
  let {
    title,
    value,
    subtitle = '',
    accent = '#ff2d96'
  }: {
    title: string;
    value: string | number;
    subtitle?: string;
    accent?: string;
  } = $props();
</script>

<div
  class="rounded-2xl bg-white p-5 shadow-md"
  style={`border-top: 4px solid ${accent};`}
>
  <p class="text-sm text-[#9c7b7b]">{title}</p>
  <h3 class="mt-1 text-2xl font-bold text-[#6b4f4f]">{value}</h3>

  {#if subtitle}
    <p class="mt-2 text-sm text-[#b08c8c]">{subtitle}</p>
  {/if}
</div>