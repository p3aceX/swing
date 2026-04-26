package com.google.android.gms.internal.p002firebaseauthapi;

import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.common.internal.F;
import g1.f;

/* JADX INFO: loaded from: classes.dex */
final class zzacs extends zzadk implements zzaee {
    private zzacm zza;
    private zzacp zzb;
    private zzadp zzc;
    private final zzact zzd;
    private final f zze;
    private String zzf;
    private zzacv zzg;

    public zzacs(f fVar, zzact zzactVar) {
        this(fVar, zzactVar, null, null, null);
    }

    private final zzacv zzb() {
        if (this.zzg == null) {
            this.zzg = new zzacv(this.zze, this.zzd.zzb());
        }
        return this.zzg;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzaej zzaejVar, zzadm<zzaem> zzadmVar) {
        F.g(zzaejVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/createAuthUri", this.zzf), zzaejVar, zzadmVar, zzaem.class, zzacmVar.zza);
    }

    private zzacs(f fVar, zzact zzactVar, zzadp zzadpVar, zzacm zzacmVar, zzacp zzacpVar) {
        this.zze = fVar;
        fVar.a();
        this.zzf = fVar.f4309c.f4318a;
        F.g(zzactVar);
        this.zzd = zzactVar;
        zza(null, null, null);
        zzaec.zza(this.zzf, this);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzael zzaelVar, zzadm<Void> zzadmVar) {
        F.g(zzaelVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/deleteAccount", this.zzf), zzaelVar, zzadmVar, Void.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzaeo zzaeoVar, zzadm<zzaen> zzadmVar) {
        F.g(zzaeoVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/emailLinkSignin", this.zzf), zzaeoVar, zzadmVar, zzaen.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzaeq zzaeqVar, zzadm<zzaep> zzadmVar) {
        F.g(zzaeqVar);
        F.g(zzadmVar);
        zzacp zzacpVar = this.zzb;
        zzadl.zza(zzacpVar.zza("/accounts/mfaEnrollment:finalize", this.zzf), zzaeqVar, zzadmVar, zzaep.class, zzacpVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzaes zzaesVar, zzadm<zzaer> zzadmVar) {
        F.g(zzaesVar);
        F.g(zzadmVar);
        zzacp zzacpVar = this.zzb;
        zzadl.zza(zzacpVar.zza("/accounts/mfaSignIn:finalize", this.zzf), zzaesVar, zzadmVar, zzaer.class, zzacpVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzafa zzafaVar, zzadm<zzafm> zzadmVar) {
        F.g(zzafaVar);
        F.g(zzadmVar);
        zzadp zzadpVar = this.zzc;
        zzadl.zza(zzadpVar.zza("/token", this.zzf), zzafaVar, zzadmVar, zzafm.class, zzadpVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzaez zzaezVar, zzadm<zzafc> zzadmVar) {
        F.g(zzaezVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/getAccountInfo", this.zzf), zzaezVar, zzadmVar, zzafc.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzafd zzafdVar, zzadm<zzafg> zzadmVar) {
        F.g(zzafdVar);
        F.g(zzadmVar);
        if (zzafdVar.zzb() != null) {
            zzb().zzb(zzafdVar.zzb().f5187n);
        }
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/getOobConfirmationCode", this.zzf), zzafdVar, zzadmVar, zzafg.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzaff zzaffVar, zzadm<zzafi> zzadmVar) {
        F.g(zzaffVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/getRecaptchaParam", this.zzf), zzadmVar, zzafi.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzafk zzafkVar, zzadm<zzafj> zzadmVar) {
        F.g(zzafkVar);
        F.g(zzadmVar);
        zzacp zzacpVar = this.zzb;
        zzadl.zza(zzacpVar.zza("/recaptchaConfig", this.zzf) + "&clientType=" + zzafkVar.zzb() + "&version=" + zzafkVar.zzc(), zzadmVar, zzafj.class, zzacpVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaee
    public final void zza() {
        zza(null, null, null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzafw zzafwVar, zzadm<zzafv> zzadmVar) {
        F.g(zzafwVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/resetPassword", this.zzf), zzafwVar, zzadmVar, zzafv.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzafy zzafyVar, zzadm<zzaga> zzadmVar) {
        F.g(zzafyVar);
        F.g(zzadmVar);
        zzacp zzacpVar = this.zzb;
        zzadl.zza(zzacpVar.zza("/accounts:revokeToken", this.zzf), zzafyVar, zzadmVar, zzaga.class, zzacpVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzafz zzafzVar, zzadm<zzagc> zzadmVar) {
        F.g(zzafzVar);
        F.g(zzadmVar);
        if (!TextUtils.isEmpty(zzafzVar.zzc())) {
            zzb().zzb(zzafzVar.zzc());
        }
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/sendVerificationCode", this.zzf), zzafzVar, zzadmVar, zzagc.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzagb zzagbVar, zzadm<zzage> zzadmVar) {
        F.g(zzagbVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/setAccountInfo", this.zzf), zzagbVar, zzadmVar, zzage.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(String str, zzadm<Void> zzadmVar) {
        F.g(zzadmVar);
        zzb().zza(str);
        zzadmVar.zza((Void) null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzagd zzagdVar, zzadm<zzagg> zzadmVar) {
        F.g(zzagdVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/signupNewUser", this.zzf), zzagdVar, zzadmVar, zzagg.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzagf zzagfVar, zzadm<zzagi> zzadmVar) {
        F.g(zzagfVar);
        F.g(zzadmVar);
        if (zzagfVar instanceof zzagj) {
            zzagj zzagjVar = (zzagj) zzagfVar;
            if (!TextUtils.isEmpty(zzagjVar.zzb())) {
                zzb().zzb(zzagjVar.zzb());
            }
        }
        zzacp zzacpVar = this.zzb;
        zzadl.zza(zzacpVar.zza("/accounts/mfaEnrollment:start", this.zzf), zzagfVar, zzadmVar, zzagi.class, zzacpVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzagh zzaghVar, zzadm<zzagk> zzadmVar) {
        F.g(zzaghVar);
        F.g(zzadmVar);
        if (!TextUtils.isEmpty(zzaghVar.zzb())) {
            zzb().zzb(zzaghVar.zzb());
        }
        zzacp zzacpVar = this.zzb;
        zzadl.zza(zzacpVar.zza("/accounts/mfaSignIn:start", this.zzf), zzaghVar, zzadmVar, zzagk.class, zzacpVar.zza);
    }

    private final void zza(zzadp zzadpVar, zzacm zzacmVar, zzacp zzacpVar) {
        this.zzc = null;
        this.zza = null;
        this.zzb = null;
        String strZza = zzadz.zza("firebear.secureToken");
        if (TextUtils.isEmpty(strZza)) {
            strZza = zzaec.zzd(this.zzf);
        } else {
            Log.e("LocalClient", "Found hermetic configuration for secureToken URL: " + strZza);
        }
        if (this.zzc == null) {
            this.zzc = new zzadp(strZza, zzb());
        }
        String strZza2 = zzadz.zza("firebear.identityToolkit");
        if (TextUtils.isEmpty(strZza2)) {
            strZza2 = zzaec.zzb(this.zzf);
        } else {
            Log.e("LocalClient", "Found hermetic configuration for identityToolkit URL: " + strZza2);
        }
        if (this.zza == null) {
            this.zza = new zzacm(strZza2, zzb());
        }
        String strZza3 = zzadz.zza("firebear.identityToolkitV2");
        if (TextUtils.isEmpty(strZza3)) {
            strZza3 = zzaec.zzc(this.zzf);
        } else {
            Log.e("LocalClient", "Found hermetic configuration for identityToolkitV2 URL: " + strZza3);
        }
        if (this.zzb == null) {
            this.zzb = new zzacp(strZza3, zzb());
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzags zzagsVar, zzadm<zzagu> zzadmVar) {
        F.g(zzagsVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/verifyAssertion", this.zzf), zzagsVar, zzadmVar, zzagu.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzagt zzagtVar, zzadm<zzagw> zzadmVar) {
        F.g(zzagtVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/verifyCustomToken", this.zzf), zzagtVar, zzadmVar, zzagw.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzagv zzagvVar, zzadm<zzagy> zzadmVar) {
        F.g(zzagvVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/verifyPassword", this.zzf), zzagvVar, zzadmVar, zzagy.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzagx zzagxVar, zzadm<zzaha> zzadmVar) {
        F.g(zzagxVar);
        F.g(zzadmVar);
        zzacm zzacmVar = this.zza;
        zzadl.zza(zzacmVar.zza("/verifyPhoneNumber", this.zzf), zzagxVar, zzadmVar, zzaha.class, zzacmVar.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadk
    public final void zza(zzagz zzagzVar, zzadm<zzahc> zzadmVar) {
        F.g(zzagzVar);
        F.g(zzadmVar);
        zzacp zzacpVar = this.zzb;
        zzadl.zza(zzacpVar.zza("/accounts/mfaEnrollment:withdraw", this.zzf), zzagzVar, zzadmVar, zzahc.class, zzacpVar.zza);
    }
}
