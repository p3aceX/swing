package x0;

import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.s;

/* JADX INFO: renamed from: x0.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0715c implements s {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Status f6758a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final GoogleSignInAccount f6759b;

    public C0715c(GoogleSignInAccount googleSignInAccount, Status status) {
        this.f6759b = googleSignInAccount;
        this.f6758a = status;
    }

    @Override // com.google.android.gms.common.api.s
    public final Status getStatus() {
        return this.f6758a;
    }
}
