package com.google.android.gms.internal.p002firebaseauthapi;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.CharConversionException;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.KeyStoreException;
import java.security.ProviderException;

/* JADX INFO: loaded from: classes.dex */
public final class zzlx {
    private static final Object zza = new Object();
    private static final String zzb = "zzlx";
    private final zzce zzc;
    private final zzbh zzd;
    private zzcc zze;

    public static final class zza {
        private Context zza = null;
        private String zzb = null;
        private String zzc = null;
        private String zzd = null;
        private zzbh zze = null;
        private boolean zzf = true;
        private zzbv zzg = null;
        private zzvd zzh = null;
        private zzcc zzi;

        private static zzcc zza(byte[] bArr) {
            return zzcc.zza(zzbm.zza(zzbk.zza(bArr)));
        }

        private final zzbh zzb() throws KeyStoreException {
            if (!zzlx.zzd()) {
                Log.w(zzlx.zzb, "Android Keystore requires at least Android M");
                return null;
            }
            zzma zzmaVar = new zzma();
            try {
                boolean zZzc = zzma.zzc(this.zzd);
                try {
                    return zzmaVar.zza(this.zzd);
                } catch (GeneralSecurityException | ProviderException e) {
                    if (!zZzc) {
                        throw new KeyStoreException(S.g("the master key ", this.zzd, " exists but is unusable"), e);
                    }
                    Log.w(zzlx.zzb, "cannot use Android Keystore, it'll be disabled", e);
                    return null;
                }
            } catch (GeneralSecurityException | ProviderException e4) {
                Log.w(zzlx.zzb, "cannot use Android Keystore, it'll be disabled", e4);
                return null;
            }
        }

        public final zza zza(zzvd zzvdVar) {
            this.zzh = zzvdVar;
            return this;
        }

        public final zza zza(String str) {
            if (str.startsWith("android-keystore://")) {
                if (this.zzf) {
                    this.zzd = str;
                    return this;
                }
                throw new IllegalArgumentException("cannot call withMasterKeyUri() after calling doNotUseKeystore()");
            }
            throw new IllegalArgumentException("key URI must start with android-keystore://");
        }

        public final zza zza(Context context, String str, String str2) {
            if (context != null) {
                this.zza = context;
                this.zzb = str;
                this.zzc = str2;
                return this;
            }
            throw new IllegalArgumentException("need an Android context");
        }

        public final synchronized zzlx zza() {
            zzlx zzlxVar;
            try {
                if (this.zzb != null) {
                    zzvd zzvdVar = this.zzh;
                    if (zzvdVar != null && this.zzg == null) {
                        this.zzg = zzbv.zza(zzcv.zza(zzvdVar.zzj()));
                    }
                    synchronized (zzlx.zza) {
                        try {
                            byte[] bArrZzb = zzb(this.zza, this.zzb, this.zzc);
                            if (bArrZzb == null) {
                                if (this.zzd != null) {
                                    this.zze = zzb();
                                }
                                if (this.zzg != null) {
                                    zzcc zzccVarZza = zzcc.zzb().zza(this.zzg);
                                    zzcc zzccVarZza2 = zzccVarZza.zza(zzccVarZza.zza().zzc().zza(0).zza());
                                    zzlx.zza(zzccVarZza2.zza(), new zzmc(this.zza, this.zzb, this.zzc), this.zze);
                                    this.zzi = zzccVarZza2;
                                } else {
                                    throw new GeneralSecurityException("cannot read or generate keyset");
                                }
                            } else if (this.zzd != null && zzlx.zzd()) {
                                this.zzi = zzb(bArrZzb);
                            } else {
                                this.zzi = zza(bArrZzb);
                            }
                            zzlxVar = new zzlx(this);
                        } finally {
                        }
                    }
                } else {
                    throw new IllegalArgumentException("keysetName cannot be null");
                }
            } catch (Throwable th) {
                throw th;
            }
            return zzlxVar;
        }

        private final zzcc zzb(byte[] bArr) {
            try {
                this.zze = new zzma().zza(this.zzd);
                try {
                    return zzcc.zza(zzby.zza(zzbk.zza(bArr), this.zze));
                } catch (IOException | GeneralSecurityException e) {
                    try {
                        return zza(bArr);
                    } catch (IOException unused) {
                        throw e;
                    }
                }
            } catch (GeneralSecurityException | ProviderException e4) {
                try {
                    zzcc zzccVarZza = zza(bArr);
                    Log.w(zzlx.zzb, "cannot use Android Keystore, it'll be disabled", e4);
                    return zzccVarZza;
                } catch (IOException unused2) {
                    throw e4;
                }
            }
        }

        private static byte[] zzb(Context context, String str, String str2) throws CharConversionException {
            SharedPreferences sharedPreferences;
            if (str != null) {
                Context applicationContext = context.getApplicationContext();
                if (str2 == null) {
                    sharedPreferences = PreferenceManager.getDefaultSharedPreferences(applicationContext);
                } else {
                    sharedPreferences = applicationContext.getSharedPreferences(str2, 0);
                }
                try {
                    String string = sharedPreferences.getString(str, null);
                    if (string == null) {
                        return null;
                    }
                    return zzxh.zza(string);
                } catch (ClassCastException | IllegalArgumentException unused) {
                    throw new CharConversionException(S.g("can't read keyset; the pref value ", str, " is not a valid hex string"));
                }
            }
            throw new IllegalArgumentException("keysetName cannot be null");
        }
    }

    public static /* synthetic */ boolean zzd() {
        return true;
    }

    public final synchronized zzby zza() {
        return this.zze.zza();
    }

    private zzlx(zza zzaVar) {
        this.zzc = new zzmc(zzaVar.zza, zzaVar.zzb, zzaVar.zzc);
        this.zzd = zzaVar.zze;
        this.zze = zzaVar.zzi;
    }

    public static /* synthetic */ void zza(zzby zzbyVar, zzce zzceVar, zzbh zzbhVar) throws GeneralSecurityException {
        try {
            if (zzbhVar != null) {
                zzbyVar.zza(zzceVar, zzbhVar);
            } else {
                zzbm.zza(zzbyVar, zzceVar);
            }
        } catch (IOException e) {
            throw new GeneralSecurityException(e);
        }
    }
}
