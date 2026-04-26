package j1;

import com.google.android.gms.internal.p002firebaseauthapi.zzafm;
import com.google.firebase.auth.FirebaseAuth;

/* JADX INFO: renamed from: j1.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0462g implements k1.s {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ FirebaseAuth f5200a;

    public C0462g(FirebaseAuth firebaseAuth) {
        this.f5200a = firebaseAuth;
    }

    @Override // k1.s
    public final void a(zzafm zzafmVar, l lVar) {
        com.google.android.gms.common.internal.F.g(zzafmVar);
        com.google.android.gms.common.internal.F.g(lVar);
        ((k1.e) lVar).f5512a = zzafmVar;
        FirebaseAuth firebaseAuth = this.f5200a;
        firebaseAuth.getClass();
        FirebaseAuth.c(firebaseAuth, lVar, zzafmVar, true, false);
    }
}
