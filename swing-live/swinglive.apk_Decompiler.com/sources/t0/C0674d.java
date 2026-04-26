package t0;

import K.k;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.auth.zzbz;
import j1.C0454D;
import java.util.ArrayList;
import java.util.Map;

/* JADX INFO: renamed from: t0.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0674d extends zzbz {
    public static final Parcelable.Creator<C0674d> CREATOR = new C0454D(10);

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final n.b f6539m;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6540a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public ArrayList f6541b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public ArrayList f6542c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ArrayList f6543d;
    public ArrayList e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public ArrayList f6544f;

    static {
        n.b bVar = new n.b();
        f6539m = bVar;
        bVar.put("registered", E0.a.b(2, "registered"));
        bVar.put("in_progress", E0.a.b(3, "in_progress"));
        bVar.put("success", E0.a.b(4, "success"));
        bVar.put("failed", E0.a.b(5, "failed"));
        bVar.put("escrowed", E0.a.b(6, "escrowed"));
    }

    public C0674d(int i4, ArrayList arrayList, ArrayList arrayList2, ArrayList arrayList3, ArrayList arrayList4, ArrayList arrayList5) {
        this.f6540a = i4;
        this.f6541b = arrayList;
        this.f6542c = arrayList2;
        this.f6543d = arrayList3;
        this.e = arrayList4;
        this.f6544f = arrayList5;
    }

    @Override // E0.b
    public final Map getFieldMappings() {
        return f6539m;
    }

    @Override // E0.b
    public final Object getFieldValue(E0.a aVar) {
        switch (aVar.f283m) {
            case 1:
                return Integer.valueOf(this.f6540a);
            case 2:
                return this.f6541b;
            case 3:
                return this.f6542c;
            case 4:
                return this.f6543d;
            case 5:
                return this.e;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return this.f6544f;
            default:
                throw new IllegalStateException("Unknown SafeParcelable id=" + aVar.f283m);
        }
    }

    @Override // E0.b
    public final boolean isFieldSet(E0.a aVar) {
        return true;
    }

    @Override // E0.b
    public final void setStringsInternal(E0.a aVar, String str, ArrayList arrayList) {
        int i4 = aVar.f283m;
        if (i4 == 2) {
            this.f6541b = arrayList;
            return;
        }
        if (i4 == 3) {
            this.f6542c = arrayList;
            return;
        }
        if (i4 == 4) {
            this.f6543d = arrayList;
        } else if (i4 == 5) {
            this.e = arrayList;
        } else {
            if (i4 != 6) {
                throw new IllegalArgumentException(String.format("Field with id=%d is not known to be a string list.", Integer.valueOf(i4)));
            }
            this.f6544f = arrayList;
        }
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6540a);
        AbstractC0184a.j0(parcel, 2, this.f6541b);
        AbstractC0184a.j0(parcel, 3, this.f6542c);
        AbstractC0184a.j0(parcel, 4, this.f6543d);
        AbstractC0184a.j0(parcel, 5, this.e);
        AbstractC0184a.j0(parcel, 6, this.f6544f);
        AbstractC0184a.n0(iM0, parcel);
    }
}
