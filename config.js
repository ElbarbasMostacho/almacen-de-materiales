// Configuración del sitio. Lo único que hay que completar es SUPABASE_ANON_KEY
// (Supabase → Project Settings → API Keys → clave "anon" / "publishable").
// Esa clave es pública por diseño: la seguridad la dan las políticas RLS de supabase.sql.
window.SITIO = {
  SUPABASE_URL: 'https://tlvmfgwbvsnugsfsrhhw.supabase.co',
  SUPABASE_ANON_KEY: 'sb_publishable_VIasW_T96BAmzs8yw-c_Zg_TSOzSTlN',
  BUCKET: 'publicaciones',
  WHATSAPP: '5492984367782',
  WHATSAPP_VISIBLE: '2984 36-7782',
  INSTAGRAM: 'https://www.instagram.com/almacen_de_materiales/',
  NOMBRE: 'Almacén de Materiales',
};

window.linkWhatsApp = function (texto) {
  return 'https://wa.me/' + window.SITIO.WHATSAPP + (texto ? '?text=' + encodeURIComponent(texto) : '');
};
