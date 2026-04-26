package j1;

import M0.C0087x;
import android.accounts.Account;
import android.app.PendingIntent;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.auth.TokenData;
import com.google.android.gms.auth.api.identity.AuthorizationRequest;
import com.google.android.gms.auth.api.identity.SaveAccountLinkingTokenRequest;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.p002firebaseauthapi.zzags;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.ArrayList;
import java.util.HashSet;
import q0.C0627a;
import q0.C0628b;
import q0.C0629c;
import t0.C0671a;
import t0.C0672b;
import t0.C0674d;
import t0.C0675e;
import u0.C0687a;

/* JADX INFO: renamed from: j1.D, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0454D implements Parcelable.Creator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5169a;

    public /* synthetic */ C0454D(int i4) {
        this.f5169a = i4;
    }

    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        switch (this.f5169a) {
            case 0:
                int iI0 = H0.a.i0(parcel);
                String strQ = null;
                String strQ2 = null;
                String strQ3 = null;
                String strQ4 = null;
                String strQ5 = null;
                String strQ6 = null;
                String strQ7 = null;
                boolean zS = false;
                boolean zS2 = false;
                int iU = 0;
                while (parcel.dataPosition() < iI0) {
                    int i4 = parcel.readInt();
                    switch ((char) i4) {
                        case 1:
                            strQ = H0.a.q(i4, parcel);
                            break;
                        case 2:
                            strQ2 = H0.a.q(i4, parcel);
                            break;
                        case 3:
                            strQ3 = H0.a.q(i4, parcel);
                            break;
                        case 4:
                            strQ4 = H0.a.q(i4, parcel);
                            break;
                        case 5:
                            zS = H0.a.S(i4, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            strQ5 = H0.a.q(i4, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            zS2 = H0.a.S(i4, parcel);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            strQ6 = H0.a.q(i4, parcel);
                            break;
                        case '\t':
                            iU = H0.a.U(i4, parcel);
                            break;
                        case '\n':
                            strQ7 = H0.a.q(i4, parcel);
                            break;
                        default:
                            H0.a.e0(i4, parcel);
                            break;
                    }
                }
                H0.a.y(iI0, parcel);
                return new C0456a(strQ, strQ2, strQ3, strQ4, zS, strQ5, zS2, strQ6, iU, strQ7);
            case 1:
                int iI02 = H0.a.i0(parcel);
                while (parcel.dataPosition() < iI02) {
                    H0.a.e0(parcel.readInt(), parcel);
                }
                H0.a.y(iI02, parcel);
                return new r();
            case 2:
                int iI03 = H0.a.i0(parcel);
                String strQ8 = null;
                String strQ9 = null;
                String strQ10 = null;
                zzags zzagsVar = null;
                String strQ11 = null;
                String strQ12 = null;
                String strQ13 = null;
                while (parcel.dataPosition() < iI03) {
                    int i5 = parcel.readInt();
                    switch ((char) i5) {
                        case 1:
                            strQ8 = H0.a.q(i5, parcel);
                            break;
                        case 2:
                            strQ9 = H0.a.q(i5, parcel);
                            break;
                        case 3:
                            strQ10 = H0.a.q(i5, parcel);
                            break;
                        case 4:
                            zzagsVar = (zzags) H0.a.o(parcel, i5, zzags.CREATOR);
                            break;
                        case 5:
                            strQ11 = H0.a.q(i5, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            strQ12 = H0.a.q(i5, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            strQ13 = H0.a.q(i5, parcel);
                            break;
                        default:
                            H0.a.e0(i5, parcel);
                            break;
                    }
                }
                H0.a.y(iI03, parcel);
                return new C0455E(strQ8, strQ9, strQ10, zzagsVar, strQ11, strQ12, strQ13);
            case 3:
                int iI04 = H0.a.i0(parcel);
                String strQ14 = null;
                String strQ15 = null;
                String strQ16 = null;
                String strQ17 = null;
                boolean zS3 = false;
                while (parcel.dataPosition() < iI04) {
                    int i6 = parcel.readInt();
                    char c5 = (char) i6;
                    if (c5 == 1) {
                        strQ14 = H0.a.q(i6, parcel);
                    } else if (c5 == 2) {
                        strQ15 = H0.a.q(i6, parcel);
                    } else if (c5 == 3) {
                        strQ16 = H0.a.q(i6, parcel);
                    } else if (c5 == 4) {
                        strQ17 = H0.a.q(i6, parcel);
                    } else if (c5 != 5) {
                        H0.a.e0(i6, parcel);
                    } else {
                        zS3 = H0.a.S(i6, parcel);
                    }
                }
                H0.a.y(iI04, parcel);
                return new C0459d(strQ14, strQ15, strQ16, strQ17, zS3);
            case 4:
                int iI05 = H0.a.i0(parcel);
                String strQ18 = null;
                while (parcel.dataPosition() < iI05) {
                    int i7 = parcel.readInt();
                    if (((char) i7) != 1) {
                        H0.a.e0(i7, parcel);
                    } else {
                        strQ18 = H0.a.q(i7, parcel);
                    }
                }
                H0.a.y(iI05, parcel);
                return new C0460e(strQ18);
            case 5:
                int iI06 = H0.a.i0(parcel);
                String strQ19 = null;
                String strQ20 = null;
                int iU2 = 0;
                int iU3 = 0;
                int iU4 = 0;
                long jW = 0;
                while (parcel.dataPosition() < iI06) {
                    int i8 = parcel.readInt();
                    switch ((char) i8) {
                        case 1:
                            iU2 = H0.a.U(i8, parcel);
                            break;
                        case 2:
                            jW = H0.a.W(i8, parcel);
                            break;
                        case 3:
                            strQ19 = H0.a.q(i8, parcel);
                            break;
                        case 4:
                            iU3 = H0.a.U(i8, parcel);
                            break;
                        case 5:
                            iU4 = H0.a.U(i8, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            strQ20 = H0.a.q(i8, parcel);
                            break;
                        default:
                            H0.a.e0(i8, parcel);
                            break;
                    }
                }
                H0.a.y(iI06, parcel);
                return new C0627a(iU2, jW, strQ19, iU3, iU4, strQ20);
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                int iI07 = H0.a.i0(parcel);
                String strQ21 = null;
                int iU5 = 0;
                int iU6 = 0;
                Account account = null;
                while (parcel.dataPosition() < iI07) {
                    int i9 = parcel.readInt();
                    char c6 = (char) i9;
                    if (c6 == 1) {
                        iU5 = H0.a.U(i9, parcel);
                    } else if (c6 == 2) {
                        iU6 = H0.a.U(i9, parcel);
                    } else if (c6 == 3) {
                        strQ21 = H0.a.q(i9, parcel);
                    } else if (c6 != 4) {
                        H0.a.e0(i9, parcel);
                    } else {
                        account = (Account) H0.a.o(parcel, i9, Account.CREATOR);
                    }
                }
                H0.a.y(iI07, parcel);
                return new C0628b(iU5, iU6, strQ21, account);
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                int iI08 = H0.a.i0(parcel);
                ArrayList arrayListU = null;
                int iU7 = 0;
                while (parcel.dataPosition() < iI08) {
                    int i10 = parcel.readInt();
                    char c7 = (char) i10;
                    if (c7 == 1) {
                        iU7 = H0.a.U(i10, parcel);
                    } else if (c7 != 2) {
                        H0.a.e0(i10, parcel);
                    } else {
                        arrayListU = H0.a.u(parcel, i10, C0627a.CREATOR);
                    }
                }
                H0.a.y(iI08, parcel);
                return new C0629c(iU7, arrayListU);
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                int iI09 = H0.a.i0(parcel);
                String strQ22 = null;
                Long lX = null;
                ArrayList arrayListR = null;
                String strQ23 = null;
                int iU8 = 0;
                boolean zS4 = false;
                boolean zS5 = false;
                while (parcel.dataPosition() < iI09) {
                    int i11 = parcel.readInt();
                    switch ((char) i11) {
                        case 1:
                            iU8 = H0.a.U(i11, parcel);
                            break;
                        case 2:
                            strQ22 = H0.a.q(i11, parcel);
                            break;
                        case 3:
                            lX = H0.a.X(i11, parcel);
                            break;
                        case 4:
                            zS4 = H0.a.S(i11, parcel);
                            break;
                        case 5:
                            zS5 = H0.a.S(i11, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            arrayListR = H0.a.r(i11, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            strQ23 = H0.a.q(i11, parcel);
                            break;
                        default:
                            H0.a.e0(i11, parcel);
                            break;
                    }
                }
                H0.a.y(iI09, parcel);
                return new TokenData(iU8, strQ22, lX, zS4, zS5, arrayListR, strQ23);
            case 9:
                int iI010 = H0.a.i0(parcel);
                HashSet hashSet = new HashSet();
                int iU9 = 0;
                ArrayList arrayListU2 = null;
                C0674d c0674d = null;
                int iU10 = 0;
                while (parcel.dataPosition() < iI010) {
                    int i12 = parcel.readInt();
                    char c8 = (char) i12;
                    if (c8 == 1) {
                        iU9 = H0.a.U(i12, parcel);
                        hashSet.add(1);
                    } else if (c8 == 2) {
                        arrayListU2 = H0.a.u(parcel, i12, C0675e.CREATOR);
                        hashSet.add(2);
                    } else if (c8 == 3) {
                        iU10 = H0.a.U(i12, parcel);
                        hashSet.add(3);
                    } else if (c8 != 4) {
                        H0.a.e0(i12, parcel);
                    } else {
                        c0674d = (C0674d) H0.a.o(parcel, i12, C0674d.CREATOR);
                        hashSet.add(4);
                    }
                }
                if (parcel.dataPosition() == iI010) {
                    return new C0672b(hashSet, iU9, arrayListU2, iU10, c0674d);
                }
                throw new A0.b(S.d(iI010, "Overread allowed size end="), parcel);
            case 10:
                int iI011 = H0.a.i0(parcel);
                ArrayList arrayListR2 = null;
                ArrayList arrayListR3 = null;
                ArrayList arrayListR4 = null;
                ArrayList arrayListR5 = null;
                ArrayList arrayListR6 = null;
                int iU11 = 0;
                while (parcel.dataPosition() < iI011) {
                    int i13 = parcel.readInt();
                    switch ((char) i13) {
                        case 1:
                            iU11 = H0.a.U(i13, parcel);
                            break;
                        case 2:
                            arrayListR2 = H0.a.r(i13, parcel);
                            break;
                        case 3:
                            arrayListR3 = H0.a.r(i13, parcel);
                            break;
                        case 4:
                            arrayListR4 = H0.a.r(i13, parcel);
                            break;
                        case 5:
                            arrayListR5 = H0.a.r(i13, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            arrayListR6 = H0.a.r(i13, parcel);
                            break;
                        default:
                            H0.a.e0(i13, parcel);
                            break;
                    }
                }
                H0.a.y(iI011, parcel);
                return new C0674d(iU11, arrayListR2, arrayListR3, arrayListR4, arrayListR5, arrayListR6);
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                int iI012 = H0.a.i0(parcel);
                HashSet hashSet2 = new HashSet();
                int iU12 = 0;
                t0.f fVar = null;
                String strQ24 = null;
                String strQ25 = null;
                String strQ26 = null;
                while (parcel.dataPosition() < iI012) {
                    int i14 = parcel.readInt();
                    char c9 = (char) i14;
                    if (c9 == 1) {
                        iU12 = H0.a.U(i14, parcel);
                        hashSet2.add(1);
                    } else if (c9 == 2) {
                        fVar = (t0.f) H0.a.o(parcel, i14, t0.f.CREATOR);
                        hashSet2.add(2);
                    } else if (c9 == 3) {
                        strQ24 = H0.a.q(i14, parcel);
                        hashSet2.add(3);
                    } else if (c9 == 4) {
                        strQ25 = H0.a.q(i14, parcel);
                        hashSet2.add(4);
                    } else if (c9 != 5) {
                        H0.a.e0(i14, parcel);
                    } else {
                        strQ26 = H0.a.q(i14, parcel);
                        hashSet2.add(5);
                    }
                }
                if (parcel.dataPosition() == iI012) {
                    return new C0675e(hashSet2, iU12, fVar, strQ24, strQ25, strQ26);
                }
                throw new A0.b(S.d(iI012, "Overread allowed size end="), parcel);
            case 12:
                int iI013 = H0.a.i0(parcel);
                HashSet hashSet3 = new HashSet();
                int iU13 = 0;
                String strQ27 = null;
                byte[] bArrJ = null;
                PendingIntent pendingIntent = null;
                C0671a c0671a = null;
                int iU14 = 0;
                while (parcel.dataPosition() < iI013) {
                    int i15 = parcel.readInt();
                    switch ((char) i15) {
                        case 1:
                            iU13 = H0.a.U(i15, parcel);
                            hashSet3.add(1);
                            break;
                        case 2:
                            strQ27 = H0.a.q(i15, parcel);
                            hashSet3.add(2);
                            break;
                        case 3:
                            iU14 = H0.a.U(i15, parcel);
                            hashSet3.add(3);
                            break;
                        case 4:
                            bArrJ = H0.a.j(i15, parcel);
                            hashSet3.add(4);
                            break;
                        case 5:
                            pendingIntent = (PendingIntent) H0.a.o(parcel, i15, PendingIntent.CREATOR);
                            hashSet3.add(5);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            c0671a = (C0671a) H0.a.o(parcel, i15, C0671a.CREATOR);
                            hashSet3.add(6);
                            break;
                        default:
                            H0.a.e0(i15, parcel);
                            break;
                    }
                }
                if (parcel.dataPosition() == iI013) {
                    return new t0.f(hashSet3, iU13, strQ27, iU14, bArrJ, pendingIntent, c0671a);
                }
                throw new A0.b(S.d(iI013, "Overread allowed size end="), parcel);
            case 13:
                int iI014 = H0.a.i0(parcel);
                int iU15 = 0;
                boolean zS6 = false;
                boolean zS7 = false;
                long jW2 = 0;
                while (parcel.dataPosition() < iI014) {
                    int i16 = parcel.readInt();
                    char c10 = (char) i16;
                    if (c10 == 1) {
                        iU15 = H0.a.U(i16, parcel);
                    } else if (c10 == 2) {
                        zS6 = H0.a.S(i16, parcel);
                    } else if (c10 == 3) {
                        jW2 = H0.a.W(i16, parcel);
                    } else if (c10 != 4) {
                        H0.a.e0(i16, parcel);
                    } else {
                        zS7 = H0.a.S(i16, parcel);
                    }
                }
                H0.a.y(iI014, parcel);
                return new C0671a(iU15, zS6, jW2, zS7);
            case 14:
                int iI015 = H0.a.i0(parcel);
                boolean zS8 = false;
                boolean zS9 = false;
                boolean zS10 = false;
                ArrayList arrayListU3 = null;
                String strQ28 = null;
                Account account2 = null;
                String strQ29 = null;
                String strQ30 = null;
                while (parcel.dataPosition() < iI015) {
                    int i17 = parcel.readInt();
                    switch ((char) i17) {
                        case 1:
                            arrayListU3 = H0.a.u(parcel, i17, Scope.CREATOR);
                            break;
                        case 2:
                            strQ28 = H0.a.q(i17, parcel);
                            break;
                        case 3:
                            zS8 = H0.a.S(i17, parcel);
                            break;
                        case 4:
                            zS9 = H0.a.S(i17, parcel);
                            break;
                        case 5:
                            account2 = (Account) H0.a.o(parcel, i17, Account.CREATOR);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            strQ29 = H0.a.q(i17, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            strQ30 = H0.a.q(i17, parcel);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            zS10 = H0.a.S(i17, parcel);
                            break;
                        default:
                            H0.a.e0(i17, parcel);
                            break;
                    }
                }
                H0.a.y(iI015, parcel);
                return new AuthorizationRequest(arrayListU3, strQ28, zS8, zS9, account2, strQ29, strQ30, zS10);
            case 15:
                int iI016 = H0.a.i0(parcel);
                String strQ31 = null;
                String strQ32 = null;
                String strQ33 = null;
                ArrayList arrayListR7 = null;
                GoogleSignInAccount googleSignInAccount = null;
                PendingIntent pendingIntent2 = null;
                while (parcel.dataPosition() < iI016) {
                    int i18 = parcel.readInt();
                    switch ((char) i18) {
                        case 1:
                            strQ31 = H0.a.q(i18, parcel);
                            break;
                        case 2:
                            strQ32 = H0.a.q(i18, parcel);
                            break;
                        case 3:
                            strQ33 = H0.a.q(i18, parcel);
                            break;
                        case 4:
                            arrayListR7 = H0.a.r(i18, parcel);
                            break;
                        case 5:
                            googleSignInAccount = (GoogleSignInAccount) H0.a.o(parcel, i18, GoogleSignInAccount.CREATOR);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            pendingIntent2 = (PendingIntent) H0.a.o(parcel, i18, PendingIntent.CREATOR);
                            break;
                        default:
                            H0.a.e0(i18, parcel);
                            break;
                    }
                }
                H0.a.y(iI016, parcel);
                return new C0687a(strQ31, strQ32, strQ33, arrayListR7, googleSignInAccount, pendingIntent2);
            case 16:
                int iI017 = H0.a.i0(parcel);
                u0.e eVar = null;
                u0.b bVar = null;
                String strQ34 = null;
                u0.d dVar = null;
                u0.c cVar = null;
                boolean zS11 = false;
                int iU16 = 0;
                while (parcel.dataPosition() < iI017) {
                    int i19 = parcel.readInt();
                    switch ((char) i19) {
                        case 1:
                            eVar = (u0.e) H0.a.o(parcel, i19, u0.e.CREATOR);
                            break;
                        case 2:
                            bVar = (u0.b) H0.a.o(parcel, i19, u0.b.CREATOR);
                            break;
                        case 3:
                            strQ34 = H0.a.q(i19, parcel);
                            break;
                        case 4:
                            zS11 = H0.a.S(i19, parcel);
                            break;
                        case 5:
                            iU16 = H0.a.U(i19, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            dVar = (u0.d) H0.a.o(parcel, i19, u0.d.CREATOR);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            cVar = (u0.c) H0.a.o(parcel, i19, u0.c.CREATOR);
                            break;
                        default:
                            H0.a.e0(i19, parcel);
                            break;
                    }
                }
                H0.a.y(iI017, parcel);
                return new u0.f(eVar, bVar, strQ34, zS11, iU16, dVar, cVar);
            case 17:
                int iI018 = H0.a.i0(parcel);
                PendingIntent pendingIntent3 = null;
                while (parcel.dataPosition() < iI018) {
                    int i20 = parcel.readInt();
                    if (((char) i20) != 1) {
                        H0.a.e0(i20, parcel);
                    } else {
                        pendingIntent3 = (PendingIntent) H0.a.o(parcel, i20, PendingIntent.CREATOR);
                    }
                }
                H0.a.y(iI018, parcel);
                return new u0.g(pendingIntent3);
            case 18:
                int iI019 = H0.a.i0(parcel);
                int iU17 = 0;
                while (parcel.dataPosition() < iI019) {
                    int i21 = parcel.readInt();
                    if (((char) i21) != 1) {
                        H0.a.e0(i21, parcel);
                    } else {
                        iU17 = H0.a.U(i21, parcel);
                    }
                }
                H0.a.y(iI019, parcel);
                return new u0.h(iU17);
            case 19:
                int iI020 = H0.a.i0(parcel);
                boolean zS12 = false;
                int iU18 = 0;
                String strQ35 = null;
                String strQ36 = null;
                String strQ37 = null;
                String strQ38 = null;
                while (parcel.dataPosition() < iI020) {
                    int i22 = parcel.readInt();
                    switch ((char) i22) {
                        case 1:
                            strQ35 = H0.a.q(i22, parcel);
                            break;
                        case 2:
                            strQ36 = H0.a.q(i22, parcel);
                            break;
                        case 3:
                            strQ37 = H0.a.q(i22, parcel);
                            break;
                        case 4:
                            strQ38 = H0.a.q(i22, parcel);
                            break;
                        case 5:
                            zS12 = H0.a.S(i22, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            iU18 = H0.a.U(i22, parcel);
                            break;
                        default:
                            H0.a.e0(i22, parcel);
                            break;
                    }
                }
                H0.a.y(iI020, parcel);
                return new u0.i(strQ35, strQ36, strQ37, strQ38, zS12, iU18);
            case 20:
                int iI021 = H0.a.i0(parcel);
                boolean zS13 = false;
                boolean zS14 = false;
                boolean zS15 = false;
                String strQ39 = null;
                String strQ40 = null;
                String strQ41 = null;
                ArrayList arrayListR8 = null;
                while (parcel.dataPosition() < iI021) {
                    int i23 = parcel.readInt();
                    switch ((char) i23) {
                        case 1:
                            zS13 = H0.a.S(i23, parcel);
                            break;
                        case 2:
                            strQ39 = H0.a.q(i23, parcel);
                            break;
                        case 3:
                            strQ40 = H0.a.q(i23, parcel);
                            break;
                        case 4:
                            zS14 = H0.a.S(i23, parcel);
                            break;
                        case 5:
                            strQ41 = H0.a.q(i23, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            arrayListR8 = H0.a.r(i23, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            zS15 = H0.a.S(i23, parcel);
                            break;
                        default:
                            H0.a.e0(i23, parcel);
                            break;
                    }
                }
                H0.a.y(iI021, parcel);
                return new u0.b(zS13, strQ39, strQ40, zS14, strQ41, arrayListR8, zS15);
            case 21:
                int iI022 = H0.a.i0(parcel);
                String strQ42 = null;
                boolean zS16 = false;
                while (parcel.dataPosition() < iI022) {
                    int i24 = parcel.readInt();
                    char c11 = (char) i24;
                    if (c11 == 1) {
                        zS16 = H0.a.S(i24, parcel);
                    } else if (c11 != 2) {
                        H0.a.e0(i24, parcel);
                    } else {
                        strQ42 = H0.a.q(i24, parcel);
                    }
                }
                H0.a.y(iI022, parcel);
                return new u0.c(strQ42, zS16);
            case 22:
                int iI023 = H0.a.i0(parcel);
                byte[] bArrJ2 = null;
                boolean zS17 = false;
                String strQ43 = null;
                while (parcel.dataPosition() < iI023) {
                    int i25 = parcel.readInt();
                    char c12 = (char) i25;
                    if (c12 == 1) {
                        zS17 = H0.a.S(i25, parcel);
                    } else if (c12 == 2) {
                        bArrJ2 = H0.a.j(i25, parcel);
                    } else if (c12 != 3) {
                        H0.a.e0(i25, parcel);
                    } else {
                        strQ43 = H0.a.q(i25, parcel);
                    }
                }
                H0.a.y(iI023, parcel);
                return new u0.d(strQ43, zS17, bArrJ2);
            case 23:
                int iI024 = H0.a.i0(parcel);
                boolean zS18 = false;
                while (parcel.dataPosition() < iI024) {
                    int i26 = parcel.readInt();
                    if (((char) i26) != 1) {
                        H0.a.e0(i26, parcel);
                    } else {
                        zS18 = H0.a.S(i26, parcel);
                    }
                }
                H0.a.y(iI024, parcel);
                return new u0.e(zS18);
            case 24:
                int iI025 = H0.a.i0(parcel);
                int iU19 = 0;
                PendingIntent pendingIntent4 = null;
                String strQ44 = null;
                String strQ45 = null;
                ArrayList arrayListR9 = null;
                String strQ46 = null;
                while (parcel.dataPosition() < iI025) {
                    int i27 = parcel.readInt();
                    switch ((char) i27) {
                        case 1:
                            pendingIntent4 = (PendingIntent) H0.a.o(parcel, i27, PendingIntent.CREATOR);
                            break;
                        case 2:
                            strQ44 = H0.a.q(i27, parcel);
                            break;
                        case 3:
                            strQ45 = H0.a.q(i27, parcel);
                            break;
                        case 4:
                            arrayListR9 = H0.a.r(i27, parcel);
                            break;
                        case 5:
                            strQ46 = H0.a.q(i27, parcel);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            iU19 = H0.a.U(i27, parcel);
                            break;
                        default:
                            H0.a.e0(i27, parcel);
                            break;
                    }
                }
                H0.a.y(iI025, parcel);
                return new SaveAccountLinkingTokenRequest(pendingIntent4, strQ44, strQ45, arrayListR9, strQ46, iU19);
            case 25:
                int iI026 = H0.a.i0(parcel);
                PendingIntent pendingIntent5 = null;
                while (parcel.dataPosition() < iI026) {
                    int i28 = parcel.readInt();
                    if (((char) i28) != 1) {
                        H0.a.e0(i28, parcel);
                    } else {
                        pendingIntent5 = (PendingIntent) H0.a.o(parcel, i28, PendingIntent.CREATOR);
                    }
                }
                H0.a.y(iI026, parcel);
                return new u0.j(pendingIntent5);
            case 26:
                int iI027 = H0.a.i0(parcel);
                int iU20 = 0;
                u0.n nVar = null;
                String strQ47 = null;
                while (parcel.dataPosition() < iI027) {
                    int i29 = parcel.readInt();
                    char c13 = (char) i29;
                    if (c13 == 1) {
                        nVar = (u0.n) H0.a.o(parcel, i29, u0.n.CREATOR);
                    } else if (c13 == 2) {
                        strQ47 = H0.a.q(i29, parcel);
                    } else if (c13 != 3) {
                        H0.a.e0(i29, parcel);
                    } else {
                        iU20 = H0.a.U(i29, parcel);
                    }
                }
                H0.a.y(iI027, parcel);
                return new u0.k(nVar, strQ47, iU20);
            case 27:
                int iI028 = H0.a.i0(parcel);
                PendingIntent pendingIntent6 = null;
                while (parcel.dataPosition() < iI028) {
                    int i30 = parcel.readInt();
                    if (((char) i30) != 1) {
                        H0.a.e0(i30, parcel);
                    } else {
                        pendingIntent6 = (PendingIntent) H0.a.o(parcel, i30, PendingIntent.CREATOR);
                    }
                }
                H0.a.y(iI028, parcel);
                return new u0.l(pendingIntent6);
            case 28:
                int iI029 = H0.a.i0(parcel);
                String strQ48 = null;
                String strQ49 = null;
                String strQ50 = null;
                String strQ51 = null;
                Uri uri = null;
                String strQ52 = null;
                String strQ53 = null;
                String strQ54 = null;
                C0087x c0087x = null;
                while (parcel.dataPosition() < iI029) {
                    int i31 = parcel.readInt();
                    switch ((char) i31) {
                        case 1:
                            strQ48 = H0.a.q(i31, parcel);
                            break;
                        case 2:
                            strQ49 = H0.a.q(i31, parcel);
                            break;
                        case 3:
                            strQ50 = H0.a.q(i31, parcel);
                            break;
                        case 4:
                            strQ51 = H0.a.q(i31, parcel);
                            break;
                        case 5:
                            uri = (Uri) H0.a.o(parcel, i31, Uri.CREATOR);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            strQ52 = H0.a.q(i31, parcel);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            strQ53 = H0.a.q(i31, parcel);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            strQ54 = H0.a.q(i31, parcel);
                            break;
                        case '\t':
                            c0087x = (C0087x) H0.a.o(parcel, i31, C0087x.CREATOR);
                            break;
                        default:
                            H0.a.e0(i31, parcel);
                            break;
                    }
                }
                H0.a.y(iI029, parcel);
                return new u0.m(strQ48, strQ49, strQ50, strQ51, uri, strQ52, strQ53, strQ54, c0087x);
            default:
                int iI030 = H0.a.i0(parcel);
                String strQ55 = null;
                String strQ56 = null;
                while (parcel.dataPosition() < iI030) {
                    int i32 = parcel.readInt();
                    char c14 = (char) i32;
                    if (c14 == 1) {
                        strQ55 = H0.a.q(i32, parcel);
                    } else if (c14 != 2) {
                        H0.a.e0(i32, parcel);
                    } else {
                        strQ56 = H0.a.q(i32, parcel);
                    }
                }
                H0.a.y(iI030, parcel);
                return new u0.n(strQ55, strQ56);
        }
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ Object[] newArray(int i4) {
        switch (this.f5169a) {
            case 0:
                return new C0456a[i4];
            case 1:
                return new r[i4];
            case 2:
                return new C0455E[i4];
            case 3:
                return new C0459d[i4];
            case 4:
                return new C0460e[i4];
            case 5:
                return new C0627a[i4];
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return new C0628b[i4];
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return new C0629c[i4];
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return new TokenData[i4];
            case 9:
                return new C0672b[i4];
            case 10:
                return new C0674d[i4];
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return new C0675e[i4];
            case 12:
                return new t0.f[i4];
            case 13:
                return new C0671a[i4];
            case 14:
                return new AuthorizationRequest[i4];
            case 15:
                return new C0687a[i4];
            case 16:
                return new u0.f[i4];
            case 17:
                return new u0.g[i4];
            case 18:
                return new u0.h[i4];
            case 19:
                return new u0.i[i4];
            case 20:
                return new u0.b[i4];
            case 21:
                return new u0.c[i4];
            case 22:
                return new u0.d[i4];
            case 23:
                return new u0.e[i4];
            case 24:
                return new SaveAccountLinkingTokenRequest[i4];
            case 25:
                return new u0.j[i4];
            case 26:
                return new u0.k[i4];
            case 27:
                return new u0.l[i4];
            case 28:
                return new u0.m[i4];
            default:
                return new u0.n[i4];
        }
    }
}
