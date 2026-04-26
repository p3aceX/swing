package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import e1.AbstractC0367g;
import j1.p;
import k1.s;
import k1.t;

/* JADX INFO: loaded from: classes.dex */
final class zzaai extends zzacw<Object, s> {
    private final String zzy;
    private final String zzz;

    public zzaai(String str, String str2) {
        super(4);
        F.e(str, "code cannot be null or empty");
        this.zzy = str;
        this.zzz = str2;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final String zza() {
        return "checkActionCode";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacw
    public final void zzb() {
        char c5 = 5;
        zzafv zzafvVar = this.zzm;
        t tVar = new t();
        if (zzafvVar.zzg()) {
            zzafvVar.zzc();
        } else {
            zzafvVar.zzb();
        }
        zzafvVar.zzb();
        if (zzafvVar.zzh()) {
            String strZzd = zzafvVar.zzd();
            strZzd.getClass();
            switch (strZzd) {
                case "REVERT_SECOND_FACTOR_ADDITION":
                    c5 = 6;
                    break;
                case "PASSWORD_RESET":
                    c5 = 0;
                    break;
                case "VERIFY_EMAIL":
                    c5 = 1;
                    break;
                case "VERIFY_AND_CHANGE_EMAIL":
                    break;
                case "EMAIL_SIGNIN":
                    c5 = 4;
                    break;
                case "RECOVER_EMAIL":
                    c5 = 2;
                    break;
                default:
                    c5 = 3;
                    break;
            }
            if (c5 != 4 && c5 != 3) {
                if (zzafvVar.zzf()) {
                    String strZzb = zzafvVar.zzb();
                    p pVarA0 = AbstractC0367g.a0(zzafvVar.zza());
                    F.d(strZzb);
                    F.g(pVarA0);
                } else if (zzafvVar.zzg()) {
                    String strZzc = zzafvVar.zzc();
                    String strZzb2 = zzafvVar.zzb();
                    F.d(strZzc);
                    F.d(strZzb2);
                } else if (zzafvVar.zze()) {
                    F.d(zzafvVar.zzb());
                }
            }
        }
        zzb(tVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadh
    public final void zza(TaskCompletionSource taskCompletionSource, zzace zzaceVar) {
        this.zzg = new zzadg(this, taskCompletionSource);
        zzaceVar.zzd(this.zzy, this.zzz, this.zzb);
    }
}
