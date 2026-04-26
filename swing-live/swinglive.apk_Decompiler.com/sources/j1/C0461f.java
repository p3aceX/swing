package j1;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.internal.p002firebaseauthapi.zzafm;
import com.google.firebase.auth.FirebaseAuth;

/* JADX INFO: renamed from: j1.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0461f implements k1.i, k1.s {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5198a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ FirebaseAuth f5199b;

    public /* synthetic */ C0461f(FirebaseAuth firebaseAuth, int i4) {
        this.f5198a = i4;
        this.f5199b = firebaseAuth;
    }

    @Override // k1.s
    public final void a(zzafm zzafmVar, l lVar) {
        switch (this.f5198a) {
            case 0:
                com.google.android.gms.common.internal.F.g(zzafmVar);
                com.google.android.gms.common.internal.F.g(lVar);
                ((k1.e) lVar).f5512a = zzafmVar;
                FirebaseAuth firebaseAuth = this.f5199b;
                firebaseAuth.getClass();
                FirebaseAuth.c(firebaseAuth, lVar, zzafmVar, true, true);
                break;
            default:
                FirebaseAuth firebaseAuth2 = this.f5199b;
                firebaseAuth2.getClass();
                FirebaseAuth.c(firebaseAuth2, lVar, zzafmVar, true, true);
                break;
        }
    }

    @Override // k1.i
    public final void zza(Status status) {
        switch (this.f5198a) {
            case 0:
                int i4 = status.f3378b;
                if (i4 == 17011 || i4 == 17021 || i4 == 17005 || i4 == 17091) {
                    this.f5199b.a();
                }
                break;
            default:
                int i5 = status.f3378b;
                if (i5 == 17011 || i5 == 17021 || i5 == 17005) {
                    this.f5199b.a();
                }
                break;
        }
    }
}
