package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import e1.k;
import j1.AbstractC0458c;
import j1.q;
import k1.i;

/* JADX INFO: loaded from: classes.dex */
final class zzacy implements zzacc {
    final /* synthetic */ zzacw zza;

    public zzacy(zzacw zzacwVar) {
        this.zza = zzacwVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(Status status) {
        String str = status.f3379c;
        if (str != null) {
            if (str.contains("MISSING_MFA_PENDING_CREDENTIAL")) {
                status = new Status(17081, null);
            } else if (str.contains("MISSING_MFA_ENROLLMENT_ID")) {
                status = new Status(17082, null);
            } else if (str.contains("INVALID_MFA_PENDING_CREDENTIAL")) {
                status = new Status(17083, null);
            } else if (str.contains("MFA_ENROLLMENT_NOT_FOUND")) {
                status = new Status(17084, null);
            } else if (str.contains("ADMIN_ONLY_OPERATION")) {
                status = new Status(17085, null);
            } else if (str.contains("UNVERIFIED_EMAIL")) {
                status = new Status(17086, null);
            } else if (str.contains("SECOND_FACTOR_EXISTS")) {
                status = new Status(17087, null);
            } else if (str.contains("SECOND_FACTOR_LIMIT_EXCEEDED")) {
                status = new Status(17088, null);
            } else if (str.contains("UNSUPPORTED_FIRST_FACTOR")) {
                status = new Status(17089, null);
            } else if (str.contains("EMAIL_CHANGE_NEEDS_VERIFICATION")) {
                status = new Status(17090, null);
            }
        }
        zzacw zzacwVar = this.zza;
        if (zzacwVar.zza != 8) {
            zzacw.zza(zzacwVar, status);
            this.zza.zza(status);
        } else {
            zzacwVar.zzz = true;
            this.zza.zzx = false;
            zza(new zzadb(this, status));
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zzb(String str) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 8);
        this.zza.zzo = str;
        zza(new zzada(this, str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zzc(String str) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 7);
        zzacw zzacwVar = this.zza;
        zzacwVar.zzn = str;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zzb() {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 6);
        zzacw.zza(this.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zzc() {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 9);
        zzacw.zza(this.zza);
    }

    private final void zza(zzadd zzaddVar) {
        this.zza.zzi.execute(new zzade(this, zzaddVar));
    }

    private final void zza(Status status, AbstractC0458c abstractC0458c, String str, String str2) {
        zzacw.zza(this.zza, status);
        zzacw zzacwVar = this.zza;
        zzacwVar.zzp = abstractC0458c;
        zzacwVar.zzq = str;
        zzacwVar.zzr = str2;
        i iVar = zzacwVar.zzf;
        if (iVar != null) {
            iVar.zza(status);
        }
        this.zza.zza(status);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(String str) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 8);
        zzacw zzacwVar = this.zza;
        zzacwVar.zzo = str;
        zzacwVar.zzz = true;
        this.zza.zzx = true;
        zza(new zzadc(this, str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzaem zzaemVar) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 3);
        zzacw zzacwVar = this.zza;
        zzacwVar.zzl = zzaemVar;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza() {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 5);
        zzacw.zza(this.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzyj zzyjVar) {
        zza(zzyjVar.zza(), zzyjVar.zzb(), zzyjVar.zzc(), zzyjVar.zzd());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzyi zzyiVar) {
        zzacw zzacwVar = this.zza;
        zzacwVar.zzs = zzyiVar;
        zzacwVar.zza(k.O("REQUIRES_SECOND_FACTOR_AUTH"));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(Status status, q qVar) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 2);
        zza(status, qVar, null, null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzafi zzafiVar) {
        zzacw zzacwVar = this.zza;
        zzacwVar.zzu = zzafiVar;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzafj zzafjVar) {
        zzacw zzacwVar = this.zza;
        zzacwVar.zzt = zzafjVar;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzafm zzafmVar, zzafb zzafbVar) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type: " + i4, i4 == 2);
        zzacw zzacwVar = this.zza;
        zzacwVar.zzj = zzafmVar;
        zzacwVar.zzk = zzafbVar;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzafv zzafvVar) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 4);
        zzacw zzacwVar = this.zza;
        zzacwVar.zzm = zzafvVar;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzaga zzagaVar) {
        zzacw zzacwVar = this.zza;
        zzacwVar.zzw = zzagaVar;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzagi zzagiVar) {
        zzacw zzacwVar = this.zza;
        zzacwVar.zzv = zzagiVar;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(zzafm zzafmVar) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type: " + i4, i4 == 1);
        zzacw zzacwVar = this.zza;
        zzacwVar.zzj = zzafmVar;
        zzacw.zza(zzacwVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacc
    public final void zza(q qVar) {
        int i4 = this.zza.zza;
        F.i("Unexpected response type " + i4, i4 == 8);
        this.zza.zzz = true;
        this.zza.zzx = true;
        zza(new zzacz(this, qVar));
    }
}
