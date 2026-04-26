package com.google.android.recaptcha.internal;

import J3.i;
import P3.m;
import com.google.android.recaptcha.RecaptchaException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.zip.GZIPInputStream;

/* JADX INFO: loaded from: classes.dex */
public final class zzbq {
    private final zzh zza;
    private final zzbg zzb;

    public zzbq(zzh zzhVar, zzbg zzbgVar) {
        this.zza = zzhVar;
        this.zzb = zzbgVar;
    }

    public final zzoe zza(String str, byte[] bArr, zzbd zzbdVar) throws RecaptchaException, IOException, zzp {
        zzbb zzbbVarZza = zzbdVar.zza(zzne.VALIDATE_INPUT);
        zzbg zzbgVar = this.zzb;
        zzbgVar.zze.put(zzbbVarZza, new zzbf(zzbbVarZza, zzbgVar.zza, new zzac()));
        try {
            URLConnection uRLConnectionOpenConnection = new URL(str).openConnection();
            i.c(uRLConnectionOpenConnection, "null cannot be cast to non-null type java.net.HttpURLConnection");
            HttpURLConnection httpURLConnection = (HttpURLConnection) uRLConnectionOpenConnection;
            httpURLConnection.setRequestMethod("POST");
            httpURLConnection.setDoOutput(true);
            httpURLConnection.setRequestProperty("Accept", "application/x-protobuffer");
            try {
                httpURLConnection.connect();
                httpURLConnection.getOutputStream().write(bArr);
                if (httpURLConnection.getResponseCode() == 200) {
                    try {
                        zzoe zzoeVarZzi = zzoe.zzi(httpURLConnection.getInputStream());
                        this.zzb.zza(zzbbVarZza);
                        return zzoeVarZzi;
                    } catch (Exception unused) {
                        throw new zzp(zzn.zzc, zzl.zzR, null);
                    }
                }
                if (httpURLConnection.getResponseCode() != 400) {
                    throw zzbr.zza(httpURLConnection.getResponseCode());
                }
                zzoz zzozVarZzg = zzoz.zzg(httpURLConnection.getErrorStream());
                zzo zzoVar = zzp.zza;
                throw zzo.zza(zzozVarZzg.zzi());
            } catch (Exception e) {
                if (e instanceof zzp) {
                    throw ((zzp) e);
                }
                throw new zzp(zzn.zze, zzl.zzQ, null);
            }
        } catch (zzp e4) {
            this.zzb.zzb(zzbbVarZza, e4, null);
            throw e4.zzc();
        }
    }

    public final String zzb(zzoe zzoeVar, zzbd zzbdVar) throws Exception {
        String string;
        try {
            String strZzk = zzoeVar.zzk();
            String strZzH = zzoeVar.zzH();
            if (this.zza.zzd(strZzH)) {
                zzbb zzbbVarZza = zzbdVar.zza(zzne.LOAD_CACHE_JS);
                zzbg zzbgVar = this.zzb;
                zzbgVar.zze.put(zzbbVarZza, new zzbf(zzbbVarZza, zzbgVar.zza, new zzac()));
                try {
                    string = this.zza.zza(strZzH);
                    if (string != null) {
                        this.zzb.zza(zzbbVarZza);
                    }
                } catch (Exception unused) {
                    this.zzb.zzb(zzbbVarZza, new zzp(zzn.zzn, zzl.zzad, null), null);
                }
                this.zzb.zzb(zzbbVarZza, new zzp(zzn.zzn, zzl.zzae, null), null);
                string = null;
            } else {
                string = null;
            }
            if (string == null) {
                this.zza.zzb();
                zzbb zzbbVarZza2 = zzbdVar.zza(zzne.DOWNLOAD_JS);
                try {
                    zzbg zzbgVar2 = this.zzb;
                    zzbgVar2.zze.put(zzbbVarZza2, new zzbf(zzbbVarZza2, zzbgVar2.zza, new zzac()));
                    try {
                        try {
                            URLConnection uRLConnectionOpenConnection = new URL(strZzk).openConnection();
                            i.c(uRLConnectionOpenConnection, "null cannot be cast to non-null type java.net.HttpURLConnection");
                            HttpURLConnection httpURLConnection = (HttpURLConnection) uRLConnectionOpenConnection;
                            httpURLConnection.setRequestMethod("GET");
                            httpURLConnection.setDoInput(true);
                            httpURLConnection.setRequestProperty("Accept", "application/x-protobuffer");
                            httpURLConnection.setRequestProperty("Accept-Encoding", "gzip");
                            httpURLConnection.connect();
                            if (httpURLConnection.getResponseCode() != 200) {
                                throw new zzp(zzn.zze, new zzl(httpURLConnection.getResponseCode()), null);
                            }
                            try {
                                InputStreamReader inputStreamReader = "gzip".equals(httpURLConnection.getContentEncoding()) ? new InputStreamReader(new GZIPInputStream(httpURLConnection.getInputStream())) : new InputStreamReader(httpURLConnection.getInputStream());
                                StringWriter stringWriter = new StringWriter();
                                char[] cArr = new char[8192];
                                for (int i4 = inputStreamReader.read(cArr); i4 >= 0; i4 = inputStreamReader.read(cArr)) {
                                    stringWriter.write(cArr, 0, i4);
                                }
                                string = stringWriter.toString();
                                i.d(string, "toString(...)");
                                this.zzb.zza(zzbbVarZza2);
                                zzbb zzbbVarZza3 = zzbdVar.zza(zzne.SAVE_CACHE_JS);
                                try {
                                    zzbg zzbgVar3 = this.zzb;
                                    zzbgVar3.zze.put(zzbbVarZza3, new zzbf(zzbbVarZza3, zzbgVar3.zza, new zzac()));
                                    this.zza.zzc(strZzH, string);
                                    this.zzb.zza(zzbbVarZza3);
                                } catch (Exception unused2) {
                                    this.zzb.zzb(zzbbVarZza3, new zzp(zzn.zzn, zzl.zzaf, null), null);
                                }
                            } catch (Exception unused3) {
                                throw new zzp(zzn.zze, zzl.zzab, null);
                            }
                        } catch (Exception unused4) {
                            throw new zzp(zzn.zze, zzl.zzaa, null);
                        }
                    } catch (Exception unused5) {
                        throw new zzp(zzn.zzc, zzl.zzZ, null);
                    }
                } catch (zzp e) {
                    this.zzb.zzb(zzbbVarZza2, e, null);
                    throw e;
                }
            }
            return m.A0(zzoeVar.zzj(), "JAVASCRIPT_TAG", string);
        } catch (Exception e4) {
            if (e4 instanceof zzp) {
                throw e4;
            }
            throw new zzp(zzn.zzc, zzl.zzX, null);
        }
    }
}
