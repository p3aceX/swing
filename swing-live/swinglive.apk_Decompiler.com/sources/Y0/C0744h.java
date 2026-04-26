package y0;

import android.os.Parcel;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.o;
import com.google.android.gms.common.api.s;
import com.google.android.gms.internal.p000authapi.zbc;

/* JADX INFO: renamed from: y0.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0744h extends AbstractC0745i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6827a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ C0744h(o oVar, int i4) {
        super(oVar);
        this.f6827a = i4;
    }

    @Override // com.google.android.gms.common.api.internal.BasePendingResult
    public final /* bridge */ /* synthetic */ s createFailedResult(Status status) {
        int i4 = this.f6827a;
        return status;
    }

    @Override // com.google.android.gms.common.api.internal.AbstractC0256d
    public final void doExecute(com.google.android.gms.common.api.b bVar) {
        switch (this.f6827a) {
            case 0:
                C0741e c0741e = (C0741e) bVar;
                C0749m c0749m = (C0749m) c0741e.getService();
                BinderC0742f binderC0742f = new BinderC0742f(this, 1);
                Parcel parcelZba = c0749m.zba();
                zbc.zbd(parcelZba, binderC0742f);
                zbc.zbc(parcelZba, c0741e.f6822a);
                c0749m.zbb(102, parcelZba);
                break;
            default:
                C0741e c0741e2 = (C0741e) bVar;
                C0749m c0749m2 = (C0749m) c0741e2.getService();
                BinderC0742f binderC0742f2 = new BinderC0742f(this, 2);
                Parcel parcelZba2 = c0749m2.zba();
                zbc.zbd(parcelZba2, binderC0742f2);
                zbc.zbc(parcelZba2, c0741e2.f6822a);
                c0749m2.zbb(103, parcelZba2);
                break;
        }
    }
}
