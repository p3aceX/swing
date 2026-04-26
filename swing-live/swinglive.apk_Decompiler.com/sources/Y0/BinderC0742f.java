package y0;

import android.os.Parcel;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.internal.p000authapi.zbb;
import com.google.android.gms.internal.p000authapi.zbc;
import x0.C0715c;

/* JADX INFO: renamed from: y0.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class BinderC0742f extends zbb implements InterfaceC0748l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6823a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ AbstractC0745i f6824b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public BinderC0742f(AbstractC0745i abstractC0745i, int i4) {
        super("com.google.android.gms.auth.api.signin.internal.ISignInCallbacks");
        this.f6823a = i4;
        this.f6824b = abstractC0745i;
    }

    @Override // y0.InterfaceC0748l
    public void b(Status status) {
        switch (this.f6823a) {
            case 1:
                ((C0744h) this.f6824b).setResult(status);
                return;
            default:
                throw new UnsupportedOperationException();
        }
    }

    @Override // y0.InterfaceC0748l
    public void e(Status status) {
        switch (this.f6823a) {
            case 2:
                ((C0744h) this.f6824b).setResult(status);
                return;
            default:
                throw new UnsupportedOperationException();
        }
    }

    @Override // y0.InterfaceC0748l
    public void f(GoogleSignInAccount googleSignInAccount, Status status) {
        switch (this.f6823a) {
            case 0:
                C0743g c0743g = (C0743g) this.f6824b;
                if (googleSignInAccount != null) {
                    C0747k c0747kB0 = C0747k.b0(c0743g.f6825a);
                    GoogleSignInOptions googleSignInOptions = c0743g.f6826b;
                    synchronized (c0747kB0) {
                        ((C0738b) c0747kB0.f6831b).c(googleSignInAccount, googleSignInOptions);
                        c0747kB0.f6832c = googleSignInAccount;
                        c0747kB0.f6833d = googleSignInOptions;
                    }
                }
                c0743g.setResult(new C0715c(googleSignInAccount, status));
                return;
            default:
                throw new UnsupportedOperationException();
        }
    }

    @Override // com.google.android.gms.internal.p000authapi.zbb
    public final boolean zba(int i4, Parcel parcel, Parcel parcel2, int i5) {
        switch (i4) {
            case 101:
                GoogleSignInAccount googleSignInAccount = (GoogleSignInAccount) zbc.zba(parcel, GoogleSignInAccount.CREATOR);
                Status status = (Status) zbc.zba(parcel, Status.CREATOR);
                zbc.zbb(parcel);
                f(googleSignInAccount, status);
                break;
            case 102:
                Status status2 = (Status) zbc.zba(parcel, Status.CREATOR);
                zbc.zbb(parcel);
                b(status2);
                break;
            case 103:
                Status status3 = (Status) zbc.zba(parcel, Status.CREATOR);
                zbc.zbb(parcel);
                e(status3);
                break;
            default:
                return false;
        }
        parcel2.writeNoException();
        return true;
    }
}
