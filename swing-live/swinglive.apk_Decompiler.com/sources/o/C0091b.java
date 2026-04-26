package O;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import java.util.ArrayList;

/* JADX INFO: renamed from: O.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0091b implements Parcelable {
    public static final Parcelable.Creator<C0091b> CREATOR = new M0.W(27);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int[] f1322a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f1323b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int[] f1324c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int[] f1325d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f1326f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final int f1327m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final int f1328n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final CharSequence f1329o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final int f1330p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final CharSequence f1331q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final ArrayList f1332r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final ArrayList f1333s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final boolean f1334t;

    public C0091b(C0090a c0090a) {
        int size = c0090a.f1304a.size();
        this.f1322a = new int[size * 6];
        if (!c0090a.f1309g) {
            throw new IllegalStateException("Not on back stack");
        }
        this.f1323b = new ArrayList(size);
        this.f1324c = new int[size];
        this.f1325d = new int[size];
        int i4 = 0;
        for (int i5 = 0; i5 < size; i5++) {
            V v = (V) c0090a.f1304a.get(i5);
            int i6 = i4 + 1;
            this.f1322a[i4] = v.f1291a;
            ArrayList arrayList = this.f1323b;
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = v.f1292b;
            arrayList.add(abstractComponentCallbacksC0109u != null ? abstractComponentCallbacksC0109u.e : null);
            int[] iArr = this.f1322a;
            iArr[i6] = v.f1293c ? 1 : 0;
            iArr[i4 + 2] = v.f1294d;
            iArr[i4 + 3] = v.e;
            int i7 = i4 + 5;
            iArr[i4 + 4] = v.f1295f;
            i4 += 6;
            iArr[i7] = v.f1296g;
            this.f1324c[i5] = v.f1297h.ordinal();
            this.f1325d[i5] = v.f1298i.ordinal();
        }
        this.e = c0090a.f1308f;
        this.f1326f = c0090a.f1310h;
        this.f1327m = c0090a.f1320r;
        this.f1328n = c0090a.f1311i;
        this.f1329o = c0090a.f1312j;
        this.f1330p = c0090a.f1313k;
        this.f1331q = c0090a.f1314l;
        this.f1332r = c0090a.f1315m;
        this.f1333s = c0090a.f1316n;
        this.f1334t = c0090a.f1317o;
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeIntArray(this.f1322a);
        parcel.writeStringList(this.f1323b);
        parcel.writeIntArray(this.f1324c);
        parcel.writeIntArray(this.f1325d);
        parcel.writeInt(this.e);
        parcel.writeString(this.f1326f);
        parcel.writeInt(this.f1327m);
        parcel.writeInt(this.f1328n);
        TextUtils.writeToParcel(this.f1329o, parcel, 0);
        parcel.writeInt(this.f1330p);
        TextUtils.writeToParcel(this.f1331q, parcel, 0);
        parcel.writeStringList(this.f1332r);
        parcel.writeStringList(this.f1333s);
        parcel.writeInt(this.f1334t ? 1 : 0);
    }

    public C0091b(Parcel parcel) {
        this.f1322a = parcel.createIntArray();
        this.f1323b = parcel.createStringArrayList();
        this.f1324c = parcel.createIntArray();
        this.f1325d = parcel.createIntArray();
        this.e = parcel.readInt();
        this.f1326f = parcel.readString();
        this.f1327m = parcel.readInt();
        this.f1328n = parcel.readInt();
        Parcelable.Creator creator = TextUtils.CHAR_SEQUENCE_CREATOR;
        this.f1329o = (CharSequence) creator.createFromParcel(parcel);
        this.f1330p = parcel.readInt();
        this.f1331q = (CharSequence) creator.createFromParcel(parcel);
        this.f1332r = parcel.createStringArrayList();
        this.f1333s = parcel.createStringArrayList();
        this.f1334t = parcel.readInt() != 0;
    }
}
