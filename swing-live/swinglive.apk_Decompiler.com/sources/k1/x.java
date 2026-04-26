package k1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import com.google.android.gms.common.internal.F;
import j1.C0455E;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class x implements A0.c {
    public static final Parcelable.Creator<x> CREATOR = new C0511b(6);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public e f5555a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public w f5556b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0455E f5557c;

    public x(e eVar) {
        F.g(eVar);
        this.f5555a = eVar;
        ArrayList arrayList = eVar.e;
        this.f5556b = null;
        for (int i4 = 0; i4 < arrayList.size(); i4++) {
            if (!TextUtils.isEmpty(((c) arrayList.get(i4)).f5511n)) {
                this.f5556b = new w(((c) arrayList.get(i4)).f5506b, ((c) arrayList.get(i4)).f5511n, eVar.f5520p);
            }
        }
        if (this.f5556b == null) {
            this.f5556b = new w(eVar.f5520p);
        }
        this.f5557c = eVar.f5521q;
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f5555a, i4, false);
        AbstractC0184a.h0(parcel, 2, this.f5556b, i4, false);
        AbstractC0184a.h0(parcel, 3, this.f5557c, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
