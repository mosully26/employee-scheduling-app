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
  class="group relative overflow-hidden rounded-2xl border border-[#eee0e2] bg-white p-5 shadow-[0_10px_30px_rgba(107,79,79,0.08)] transition duration-300 hover:-translate-y-1 hover:shadow-[0_16px_38px_rgba(107,79,79,0.12)]"
>
  <div class="absolute inset-x-0 top-0 h-1" style={`background: ${accent}`}></div>
  <div class="absolute -right-8 -top-10 h-24 w-24 rounded-full opacity-[0.07]" style={`background: ${accent}`}></div>
  <div class="relative">
    <div class="mb-4 flex items-center justify-between">
      <p class="text-xs font-bold uppercase tracking-[0.16em] text-[#9c7b7b]">{title}</p>
      <span class="h-2.5 w-2.5 rounded-full" style={`background: ${accent}`}></span>
    </div>
    <h3 class="text-3xl font-bold tracking-tight text-[#5f4747]">{value}</h3>

    {#if subtitle}
      <p class="mt-2 text-sm text-[#a18484]">{subtitle}</p>
    {/if}
  </div>
</div>