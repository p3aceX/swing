package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import j1.C0456a;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class zzafd implements zzacr {
    private String zza;
    private String zzb;
    private String zzc;
    private String zzd;
    private C0456a zze;
    private String zzf;
    private String zzg;

    public zzafd(int i4) {
        this.zza = zza(i4);
    }

    public static zzafd zza(C0456a c0456a, String str, String str2) {
        F.d(str);
        F.d(str2);
        F.g(c0456a);
        return new zzafd(7, c0456a, null, str2, str, null, null);
    }

    public final C0456a zzb() {
        return this.zze;
    }

    public final zzafd zzc(String str) {
        this.zzf = str;
        return this;
    }

    public final zzafd zzd(String str) {
        F.d(str);
        this.zzd = str;
        return this;
    }

    public final zzafd zzb(String str) {
        F.d(str);
        this.zzb = str;
        return this;
    }

    private zzafd(int i4, C0456a c0456a, String str, String str2, String str3, String str4, String str5) {
        this.zza = zza(7);
        F.g(c0456a);
        this.zze = c0456a;
        this.zzb = null;
        this.zzc = str2;
        this.zzd = str3;
        this.zzf = null;
        this.zzg = null;
    }

    public final zzafd zza(C0456a c0456a) {
        F.g(c0456a);
        this.zze = c0456a;
        return this;
    }

    public final zzafd zza(String str) {
        this.zzg = str;
        return this;
    }

    private static String zza(int i4) {
        if (i4 == 1) {
            return "PASSWORD_RESET";
        }
        if (i4 == 4) {
            return "VERIFY_EMAIL";
        }
        if (i4 == 6) {
            return "EMAIL_SIGNIN";
        }
        if (i4 != 7) {
            return "REQUEST_TYPE_UNSET_ENUM_VALUE";
        }
        return "VERIFY_AND_CHANGE_EMAIL";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacr
    public final String zza() throws JSONException {
        int i4;
        i4 = 1;
        JSONObject jSONObject = new JSONObject();
        String str = this.zza;
        str.getClass();
        switch (str) {
            case "PASSWORD_RESET":
                break;
            case "VERIFY_EMAIL":
                i4 = 4;
                break;
            case "VERIFY_AND_CHANGE_EMAIL":
                i4 = 7;
                break;
            case "EMAIL_SIGNIN":
                i4 = 6;
                break;
            default:
                i4 = 0;
                break;
        }
        jSONObject.put("requestType", i4);
        String str2 = this.zzb;
        if (str2 != null) {
            jSONObject.put("email", str2);
        }
        String str3 = this.zzc;
        if (str3 != null) {
            jSONObject.put("newEmail", str3);
        }
        String str4 = this.zzd;
        if (str4 != null) {
            jSONObject.put("idToken", str4);
        }
        C0456a c0456a = this.zze;
        if (c0456a != null) {
            jSONObject.put("androidInstallApp", c0456a.e);
            jSONObject.put("canHandleCodeInApp", this.zze.f5186m);
            String str5 = this.zze.f5181a;
            if (str5 != null) {
                jSONObject.put("continueUrl", str5);
            }
            String str6 = this.zze.f5182b;
            if (str6 != null) {
                jSONObject.put("iosBundleId", str6);
            }
            String str7 = this.zze.f5183c;
            if (str7 != null) {
                jSONObject.put("iosAppStoreId", str7);
            }
            String str8 = this.zze.f5184d;
            if (str8 != null) {
                jSONObject.put("androidPackageName", str8);
            }
            String str9 = this.zze.f5185f;
            if (str9 != null) {
                jSONObject.put("androidMinimumVersion", str9);
            }
            String str10 = this.zze.f5189p;
            if (str10 != null) {
                jSONObject.put("dynamicLinkDomain", str10);
            }
        }
        String str11 = this.zzf;
        if (str11 != null) {
            jSONObject.put("tenantId", str11);
        }
        String str12 = this.zzg;
        if (str12 != null) {
            zzahb.zza(jSONObject, "captchaResp", str12);
        } else {
            zzahb.zza(jSONObject);
        }
        return jSONObject.toString();
    }
}
