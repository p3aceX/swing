package y0;

import android.content.Context;
import android.os.Parcel;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.o;
import com.google.android.gms.common.api.s;
import com.google.android.gms.internal.p000authapi.zbc;
import x0.C0715c;

/* JADX INFO: renamed from: y0.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0743g extends AbstractC0745i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ Context f6825a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ GoogleSignInOptions f6826b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0743g(o oVar, Context context, GoogleSignInOptions googleSignInOptions) {
        super(oVar);
        this.f6825a = context;
        this.f6826b = googleSignInOptions;
    }

    @Override // com.google.android.gms.common.api.internal.BasePendingResult
    public final /* synthetic */ s createFailedResult(Status status) {
        return new C0715c(null, status);
    }

    @Override // com.google.android.gms.common.api.internal.AbstractC0256d
    public final void doExecute(com.google.android.gms.common.api.b bVar) {
        C0749m c0749m = (C0749m) ((C0741e) bVar).getService();
        BinderC0742f binderC0742f = new BinderC0742f(this, 0);
        Parcel parcelZba = c0749m.zba();
        zbc.zbd(parcelZba, binderC0742f);
        zbc.zbc(parcelZba, this.f6826b);
        c0749m.zbb(101, parcelZba);
    }
}
