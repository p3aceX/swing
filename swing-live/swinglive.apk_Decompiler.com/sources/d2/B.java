package D2;

import android.view.KeyEvent;
import com.google.android.gms.auth.api.signin.internal.SignInHubActivity;
import y0.C0740d;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class B implements androidx.lifecycle.v {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f154a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f155b = false;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f156c;

    public B(C c5) {
        this.f156c = c5;
    }

    public void a(boolean z4) {
        if (this.f155b) {
            throw new IllegalStateException("The onKeyEventHandledCallback should be called exactly once.");
        }
        this.f155b = true;
        C c5 = (C) this.f156c;
        int i4 = c5.f158b - 1;
        c5.f158b = i4;
        boolean z5 = z4 | c5.f157a;
        c5.f157a = z5;
        if (i4 != 0 || z5) {
            return;
        }
        ((C0747k) c5.f160d).Q((KeyEvent) c5.f159c);
    }

    @Override // androidx.lifecycle.v
    public void m(Object obj) {
        this.f155b = true;
        B.k kVar = (B.k) this.f156c;
        kVar.getClass();
        SignInHubActivity signInHubActivity = (SignInHubActivity) kVar.f104b;
        signInHubActivity.setResult(signInHubActivity.f3366F, signInHubActivity.f3367G);
        signInHubActivity.finish();
    }

    public String toString() {
        switch (this.f154a) {
            case 1:
                return ((B.k) this.f156c).toString();
            default:
                return super.toString();
        }
    }

    public B(C0740d c0740d, B.k kVar) {
        this.f156c = kVar;
    }
}
