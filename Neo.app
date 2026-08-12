import React, { useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableOpacity,
  ScrollView,
  Modal,
  SafeAreaView,
  Alert,
  Dimensions,
  Image
} from 'react-native';

const { height } = Dimensions.get('window');

export default function App() {
  // --- Global App State ---
  const [currentScreen, setCurrentScreen] = useState('WELCOME'); // WELCOME, STUDENT_LOGIN, HOLDER_LOGIN, PENDING_APPROVAL, DASHBOARD, HOLDER_DASHBOARD
  const [userRole, setUserRole] = useState(null); // 'STUDENT' or 'HOLDER'
  
  // Holder Data
  const [holderMobile, setHolderMobile] = useState('6003481675');
  const [canChangeHolderNumber, setCanChangeHolderNumber] = useState(true);
  const [tempHolderMobile, setTempHolderMobile] = useState('');
  const [isChangingNumber, setIsChangingNumber] = useState(false);

  // Student Data & Approvals
  const [studentName, setStudentName] = useState('');
  const [studentMobile, setStudentMobile] = useState('');
  const [pendingStudents, setPendingStudents] = useState([
    { id: '1', name: 'Rahul Sharma', mobile: '9876543210' }
  ]);
  const [approvedStudents, setApprovedStudents] = useState(['9876543210']); // list of approved mobile numbers

  // Faculty Data (Managed by Holder via Swipe-up / Panel)
  const [facultyList, setFacultyList] = useState([
    { id: '1', name: 'Dr. B. Borah', qualification: 'Ph.D. in Mathematics, Cotton University', photo: 'https://via.placeholder.com/100' },
    { id: '2', name: 'Mrs. A. Das', qualification: 'M.Sc. Physics, Gauhati University', photo: 'https://via.placeholder.com/100' }
  ]);
  const [newFacName, setNewFacName] = useState('');
  const [newFacQual, setNewFacQual] = useState('');
  const [showFacultyModal, setShowFacultyModal] = useState(false);

  // App Navigation inside Student Dashboard
  const [studentTab, setStudentTab] = useState('HOME'); // HOME, DOUBT, LIVE, RECORDED, PAYMENT
  const [selectedClass, setSelectedClass] = useState(null);
  const [selectedSubject, setSelectedSubject] = useState(null);
  const [selectedStream, setSelectedStream] = useState(null); // 'ARTS' or 'SCIENCE' for 11-12

  // Doubt Solving State
  const [doubts, setDoubts] = useState([
    { id: '1', student: 'Rahul', text: 'Sir, please explain Newton’s third law.', teacherReply: '' }
  ]);
  const [newDoubt, setNewDoubt] = useState('');

  // Live Class Comments State (with Block feature)
  const [comments, setComments] = useState([
    { id: '1', user: 'Rahul', text: 'Clear audio sir!', blocked: false },
    { id: '2', user: 'SpamUser99', text: 'Check out my profile!', blocked: false }
  ]);
  const [newComment, setNewComment] = useState('');

  // --- Handlers ---
  const handleStudentLogin = () => {
    if (!studentName.trim() || !studentMobile.trim()) {
      Alert.alert('Error', 'Please enter both Name and Mobile Number.');
      return;
    }
    if (approvedStudents.includes(studentMobile)) {
      setUserRole('STUDENT');
      setCurrentScreen('DASHBOARD');
    } else {
      // Send approval request to Holder
      setPendingStudents([...pendingStudents, { id: Date.now().toString(), name: studentName, mobile: studentMobile }]);
      setCurrentScreen('PENDING_APPROVAL');
    }
  };

  const handleHolderLogin = () => {
    if (tempHolderMobile === holderMobile) {
      setUserRole('HOLDER');
      setCurrentScreen('HOLDER_DASHBOARD');
      setTempHolderMobile('');
    } else {
      Alert.alert('Error', 'Invalid Holder Mobile Number.');
    }
  };

  const approveStudent = (mobile) => {
    setApprovedStudents([...approvedStudents, mobile]);
    setPendingStudents(pendingStudents.filter(s => s.mobile !== mobile));
    Alert.alert('Success', 'Student approved successfully!');
  };

  const updateHolderNumber = () => {
    if (!canChangeHolderNumber) {
      Alert.alert('Restricted', 'You can only change the holder number once!');
      return;
    }
    if (tempHolderMobile.length === 10) {
      setHolderMobile(tempHolderMobile);
      setCanChangeHolderNumber(false);
      setIsChangingNumber(false);
      setTempHolderMobile('');
      Alert.alert('Success', 'Holder mobile number updated permanently.');
    } else {
      Alert.alert('Error', 'Enter a valid 10-digit mobile number.');
    }
  };

  // --- Render Screens ---

  // 1. Welcome Screen
  if (currentScreen === 'WELCOME') {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerCard}>
          <Text style={styles.appTitle}>POXIMA STAR ACADEMY</Text>
          <Text style={styles.subtitle}>Excellence in Education</Text>

          <TouchableOpacity style={styles.primaryButton} onPress={() => setCurrentScreen('STUDENT_LOGIN')}>
            <Text style={styles.buttonText}>Login as Student</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.secondaryButton} onPress={() => setCurrentScreen('HOLDER_LOGIN')}>
            <Text style={styles.secondaryButtonText}>Login as Holder (Admin)</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  // 2. Student Login Screen
  if (currentScreen === 'STUDENT_LOGIN') {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.card}>
          <Text style={styles.headerTitle}>Student Portal</Text>
          <TextInput
            style={styles.input}
            placeholder="Enter Your Full Name"
            placeholderTextColor="#888"
            value={studentName}
            onChangeText={setStudentName}
          />
          <TextInput
            style={styles.input}
            placeholder="Enter Contact Number"
            placeholderTextColor="#888"
            keyboardType="phone-pad"
            value={studentMobile}
            onChangeText={setStudentMobile}
          />
          <TouchableOpacity style={styles.primaryButton} onPress={handleStudentLogin}>
            <Text style={styles.buttonText}>Enter Academy</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => setCurrentScreen('WELCOME')}>
            <Text style={styles.linkText}>Back to Home</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  // 3. Holder Login Screen
  if (currentScreen === 'HOLDER_LOGIN') {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.card}>
          <Text style={styles.headerTitle}>Holder Authentication</Text>
          <TextInput
            style={styles.input}
            placeholder="Enter Holder Mobile Number"
            placeholderTextColor="#888"
            keyboardType="phone-pad"
            value={tempHolderMobile}
            onChangeText={setTempHolderMobile}
          />
          <TouchableOpacity style={styles.primaryButton} onPress={handleHolderLogin}>
            <Text style={styles.buttonText}>Verify & Login</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => setCurrentScreen('WELCOME')}>
            <Text style={styles.linkText}>Back to Home</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  // 4. Pending Approval Screen
  if (currentScreen === 'PENDING_APPROVAL') {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerCard}>
          <Text style={styles.headerTitle}>Approval Pending</Text>
          <Text style={styles.infoText}>
            Your request has been sent to the Academy Holder. Please wait until your contact number ({studentMobile}) is approved.
          </Text>
          <TouchableOpacity style={styles.secondaryButton} onPress={() => setCurrentScreen('WELCOME')}>
            <Text style={styles.secondaryButtonText}>Back to Home</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  // 5. Holder Dashboard
  if (currentScreen === 'HOLDER_DASHBOARD') {
    return (
      <SafeAreaView style={styles.container}>
        <ScrollView contentContainerStyle={styles.scrollContainer}>
          <Text style={styles.headerTitle}>Holder Dashboard</Text>
          <Text style={styles.holderInfo}>Holder Mobile: {holderMobile}</Text>

          {/* One-time Mobile Number Update */}
          {canChangeHolderNumber && (
            <View style={styles.sectionCard}>
              <Text style={styles.sectionTitle}>Update Holder Mobile (One-Time Only)</Text>
              {isChangingNumber ? (
                <>
                  <TextInput
                    style={styles.input}
                    placeholder="New Mobile Number"
                    keyboardType="phone-pad"
                    value={tempHolderMobile}
                    onChangeText={setTempHolderMobile}
                  />
                  <TouchableOpacity style={styles.primaryButton} onPress={updateHolderNumber}>
                    <Text style={styles.buttonText}>Save New Number</Text>
                  </TouchableOpacity>
                </>
              ) : (
                <TouchableOpacity style={styles.secondaryButton} onPress={() => setIsChangingNumber(true)}>
                  <Text style={styles.secondaryButtonText}>Change Holder Number</Text>
                </TouchableOpacity>
              )}
            </View>
          )}

          {/* Student Approvals */}
          <View style={styles.sectionCard}>
            <Text style={styles.sectionTitle}>Pending Student Approvals ({pendingStudents.length})</Text>
            {pendingStudents.length === 0 ? (
              <Text style={styles.subText}>No pending requests.</Text>
            ) : (
              pendingStudents.map(student => (
                <View key={student.id} style={styles.rowItem}>
                  <View>
                    <Text style={styles.boldText}>{student.name}</Text>
                    <Text style={styles.subText}>{student.mobile}</Text>
                  </View>
                  <TouchableOpacity style={styles.smallButton} onPress={() => approveStudent(student.mobile)}>
                    <Text style={styles.buttonText}>Approve</Text>
                  </TouchableOpacity>
                </View>
              ))
            )}
          </View>

          {/* Faculty Management */}
          <View style={styles.sectionCard}>
            <Text style={styles.sectionTitle}>Manage Faculty (Swipe-up Viewable)</Text>
            <TextInput
              style={styles.input}
              placeholder="Faculty Name"
              placeholderTextColor="#888"
              value={newFacName}
              onChangeText={setNewFacName}
            />
            <TextInput
              style={styles.input}
              placeholder="Qualification (e.g. M.Sc, B.Ed)"
              placeholderTextColor="#888"
              value={newFacQual}
              onChangeText={setNewFacQual}
            />
            <TouchableOpacity 
              style={styles.primaryButton} 
              onPress={() => {
                if (newFacName && newFacQual) {
                  setFacultyList([...facultyList, { id: Date.now().toString(), name: newFacName, qualification: newFacQual }]);
                  setNewFacName('');
                  setNewFacQual('');
                  Alert.alert('Success', 'Faculty added successfully!');
                }
              }}
            >
              <Text style={styles.buttonText}>Add Faculty Profile</Text>
            </TouchableOpacity>
          </View>

          <TouchableOpacity style={styles.secondaryButton} onPress={() => setCurrentScreen('WELCOME')}>
            <Text style={styles.secondaryButtonText}>Logout</Text>
          </TouchableOpacity>
        </ScrollView>
      </SafeAreaView>
    );
  }

  // 6. Student Dashboard (Core App Sessions)
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.navBar}>
        <Text style={styles.navTitle}>Poxima Star Academy</Text>
        <TouchableOpacity onPress={() => setCurrentScreen('WELCOME')}>
          <Text style={styles.logoutText}>Logout</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.mainContent}>
        {/* Navigation Tabs */}
        {studentTab === 'HOME' && (
          <ScrollView contentContainerStyle={styles.scrollContainer}>
            <Text style={styles.welcomeUser}>Welcome, {studentName}</Text>
            <View style={styles.gridContainer}>
              <TouchableOpacity style={styles.gridCard} onPress={() => setStudentTab('DOUBT')}>
                <Text style={styles.gridIcon}>❓</Text>
                <Text style={styles.gridTitle}>1. Doubt Solving</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.gridCard} onPress={() => setStudentTab('LIVE')}>
                <Text style={styles.gridIcon}>🎥</Text>
                <Text style={styles.gridTitle}>2. Live Class</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.gridCard} onPress={() => setStudentTab('RECORDED')}>
                <Text style={styles.gridIcon}>📂</Text>
                <Text style={styles.gridTitle}>3. Recorded Class</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.gridCard} onPress={() => setStudentTab('PAYMENT')}>
                <Text style={styles.gridIcon}>💳</Text>
                <Text style={styles.gridTitle}>4. Pay for Online</Text>
              </TouchableOpacity>
            </View>

            {/* Swipe Up Faculty Section Trigger */}
            <TouchableOpacity style={styles.swipeTrigger} onPress={() => setShowFacultyModal(true)}>
              <Text style={styles.swipeText}>▲ Swipe Up to View Academy Faculty & Qualifications</Text>
            </TouchableOpacity>
          </ScrollView>
        )}

        {/* 1. Doubt Solving Session */}
        {studentTab === 'DOUBT' && (
          <View style={styles.subScreen}>
            <TouchableOpacity onPress={() => setStudentTab('HOME')}><Text style={styles.backLink}>← Back</Text></TouchableOpacity>
            <Text style={styles.sectionTitle}>Doubt Solving Portal</Text>
            <ScrollView style={{ flex: 1, marginVertical: 10 }}>
              {doubts.map(d => (
                <View key={d.id} style={styles.chatBox}>
                  <Text style={styles.boldText}>Q: {d.text}</Text>
                  <Text style={styles.subText}>Teacher Reply: {d.teacherReply || 'Pending response from faculty...'}</Text>
                </View>
              ))}
            </ScrollView>
            <TextInput
              style={styles.input}
              placeholder="Ask your doubt..."
              placeholderTextColor="#888"
              value={newDoubt}
              onChangeText={setNewDoubt}
            />
            <TouchableOpacity style={styles.primaryButton} onPress={() => {
              if(newDoubt) {
                setDoubts([...doubts, { id: Date.now().toString(), student: studentName, text: newDoubt, teacherReply: '' }]);
                setNewDoubt('');
                Alert.alert('Sent', 'Doubt sent to teachers successfully.');
              }
            }}>
              <Text style={styles.buttonText}>Submit Doubt</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* 2. Live Class Session */}
        {studentTab === 'LIVE' && (
          <View style={styles.subScreen}>
            <TouchableOpacity onPress={() => setStudentTab('HOME')}><Text style={styles.backLink}>← Back</Text></TouchableOpacity>
            <Text style={styles.sectionTitle}>Live Interactive Class</Text>
            
            <View style={styles.videoPlayerPlaceholder}>
              <Text style={styles.videoPlaceholderText}>[ LIVE STREAMING ACTIVE ]</Text>
            </View>

            <Text style={styles.sectionSubTitle}>Live Chat (Class 11-12 Moderated)</Text>
            <ScrollView style={{ flex: 1, backgroundColor: '#1e1e1e', padding: 10, borderRadius: 8 }}>
              {comments.filter(c => !c.blocked).map(c => (
                <View key={c.id} style={styles.commentRow}>
                  <Text style={styles.commentUser}>{c.user}: <Text style={styles.commentText}>{c.text}</Text></Text>
                  <TouchableOpacity onPress={() => {
                    setComments(comments.map(item => item.id === c.id ? { ...item, blocked: true } : item));
                    Alert.alert('Blocked', 'User comment blocked.');
                  }}>
                    <Text style={styles.threeDots}>⋮</Text>
                  </TouchableOpacity>
                </View>
              ))}
            </ScrollView>
            <View style={styles.commentInputRow}>
              <TextInput
                style={[styles.input, { flex: 1, marginBottom: 0 }]}
                placeholder="Ask in live chat..."
                placeholderTextColor="#888"
                value={newComment}
                onChangeText={setNewComment}
              />
              <TouchableOpacity style={styles.smallButton} onPress={() => {
                if(newComment) {
                  setComments([...comments, { id: Date.now().toString(), user: studentName, text: newComment, blocked: false }]);
                  setNewComment('');
                }
              }}>
                <Text style={styles.buttonText}>Send</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}

        {/* 3. Recorded Class Session (Hierarchical Classes 6-12) */}
        {studentTab === 'RECORDED' && (
          <View style={styles.subScreen}>
            <TouchableOpacity onPress={() => {
              if (selectedSubject) setSelectedSubject(null);
              else if (selectedClass) { setSelectedClass(null); setSelectedStream(null); }
              else setStudentTab('HOME');
            }}>
              <Text style={styles.backLink}>← Back</Text>
            </TouchableOpacity>

            {!selectedClass ? (
              <ScrollView>
                <Text style={styles.sectionTitle}>Select Class (6 to 12)</Text>
                {['Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'].map(cls => (
                  <TouchableOpacity key={cls} style={styles.listCard} onPress={() => {
                    setSelectedClass(cls);
                    if (cls === 'Class 11' || cls === 'Class 12') {
                      setSelectedStream(null);
                    }
                  }}>
                    <Text style={styles.listCardText}>{cls} Recorded Lectures</Text>
                  </TouchableOpacity>
                ))}
              </ScrollView>
            ) : (selectedClass === 'Class 11' || selectedClass === 'Class 12') && !selectedStream ? (
              <ScrollView>
                <Text style={styles.sectionTitle}>{selectedClass} - Select Stream</Text>
                <TouchableOpacity style={styles.listCard} onPress={() => setSelectedStream('SCIENCE')}><Text style={styles.listCardText}>Science Section</Text></TouchableOpacity>
                <TouchableOpacity style={styles.listCard} onPress={() => setSelectedStream('ARTS')}><Text style={styles.listCardText}>Arts Section</Text></TouchableOpacity>
              </ScrollView>
            ) : !selectedSubject ? (
              <ScrollView>
                <Text style={styles.sectionTitle}>{selectedClass} {selectedStream ? `(${selectedStream})` : ''} - Subjects</Text>
                {selectedClass === 'Class 10' && ['Maths', 'Science', 'History', 'Geography', 'Assamese', 'English'].map(sub => (
                  <TouchableOpacity key={sub} style={styles.listCard} onPress={() => setSelectedSubject(sub)}><Text style={styles.listCardText}>{sub}</Text></TouchableOpacity>
                ))}
                {['Class 6', 'Class 7', 'Class 8', 'Class 9'].includes(selectedClass) && ['Maths', 'Science'].map(sub => (
                  <TouchableOpacity key={sub} style={styles.listCard} onPress={() => setSelectedSubject(sub)}><Text style={styles.listCardText}>{sub}</Text></TouchableOpacity>
                ))}
                {selectedStream === 'SCIENCE' && ['Maths', 'Physics', 'Chemistry', 'Biology', 'English', 'Assamese'].map(sub => (
                  <TouchableOpacity key={sub} style={styles.listCard} onPress={() => setSelectedSubject(sub)}><Text style={styles.listCardText}>{sub}</Text></TouchableOpacity>
                ))}
                {selectedStream === 'ARTS' && ['Geography', 'History', 'Political Science', 'Sanskrit', 'Assamese', 'English'].map(sub => (
                  <TouchableOpacity key={sub} style={styles.listCard} onPress={() => setSelectedSubject(sub)}><Text style={styles.listCardText}>{sub}</Text></TouchableOpacity>
                ))}
              </ScrollView>
            ) : (
              <ScrollView>
                <Text style={styles.sectionTitle}>{selectedSubject} Lectures ({selectedClass})</Text>
                <View style={styles.videoCard}><Text style={styles.videoTitle}>Lecture 1: Introduction & Concepts</Text></View>
                <View style={styles.videoCard}><Text style={styles.videoTitle}>Lecture 2: Advanced Problem Solving</Text></View>
              </ScrollView>
            )}
          </View>
        )}

        {/* 4. Pay for Online Session */}
        {studentTab === 'PAYMENT' && (
          <View style={styles.subScreen}>
            <TouchableOpacity onPress={() => setStudentTab('HOME')}><Text style={styles.backLink}>← Back</Text></TouchableOpacity>
            <Text style={styles.sectionTitle}>Pay for Online Courses</Text>
            <View style={styles.paymentCard}>
              <Text style={styles.paymentInfoText}>To complete course payments, please contact the Academy Holder directly at:</Text>
              <Text style={styles.holderPhoneDisplay}>📞 {holderMobile}</Text>
              <Text style={styles.subText}>Call or WhatsApp to confirm enrollment and receive payment credentials.</Text>
            </View>
          </View>
        )}
      </View>

      {/* Faculty Bottom Swipe-Up Modal */}
      <Modal visible={showFacultyModal} animationType="slide" transparent={true}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.sectionTitle}>Academy Faculty Directory</Text>
            <ScrollView style={{ maxHeight: 300 }}>
              {facultyList.map(fac => (
                <View key={fac.id} style={styles.facultyCard}>
                  <Text style={styles.boldText}>{fac.name}</Text>
                  <Text style={styles.subText}>{fac.qualification}</Text>
                </View>
              ))}
            </ScrollView>
            <TouchableOpacity style={styles.primaryButton} onPress={() => setShowFacultyModal(false)}>
              <Text style={styles.buttonText}>Close Panel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#121212' },
  centerCard: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 },
  card: { width: '90%', backgroundColor: '#1e1e1e', padding: 20, borderRadius: 12, alignSelf: 'center', marginTop: 100 },
  scrollContainer: { padding: 20 },
  appTitle: { fontSize: 24, fontWeight: 'bold', color: '#ffd700', textAlign: 'center', marginBottom: 5 },
  subtitle: { fontSize: 14, color: '#aaa', textAlign: 'center', marginBottom: 30 },
  headerTitle: { fontSize: 20, fontWeight: 'bold', color: '#fff', marginBottom: 15, textAlign: 'center' },
  sectionTitle: { fontSize: 18, fontWeight: 'bold', color: '#ffd700', marginBottom: 10 },
  sectionSubTitle: { fontSize: 14, fontWeight: '600', color: '#ccc', marginVertical: 10 },
  subText: { fontSize: 12, color: '#888', marginBottom: 5 },
  infoText: { fontSize: 14, color: '#ccc', textAlign: 'center', marginBottom: 20 },
  input: { backgroundColor: '#2a2a2a', color: '#fff', padding: 12, borderRadius: 8, marginBottom: 15, fontSize: 14, borderWidth: 1, borderColor: '#333' },
  primaryButton: { backgroundColor: '#0066cc', padding: 14, borderRadius: 8, alignItems: 'center', marginVertical: 5 },
  secondaryButton: { backgroundColor: '#333', padding: 14, borderRadius: 8, alignItems: 'center', marginVertical: 5 },
  smallButton: { backgroundColor: '#0066cc', padding: 8, borderRadius: 6, justifyContent: 'center', alignItems: 'center' },
  buttonText: { color: '#fff', fontWeight: 'bold', fontSize: 14 },
  secondaryButtonText: { color: '#ccc', fontWeight: 'bold', fontSize: 14 },
  linkText: { color: '#0066cc', textAlign: 'center', marginTop: 15 },
  navBar: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 15, backgroundColor: '#1e1e1e', borderBottomWidth: 1, borderColor: '#333' },
  navTitle: { color: '#ffd700', fontWeight: 'bold', fontSize: 16 },
  logoutText: { color: '#ff4444', fontWeight: 'bold' },
  mainContent: { flex: 1 },
  welcomeUser: { fontSize: 18, color: '#fff', fontWeight: 'bold', marginBottom: 20 },
  gridContainer: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between' },
  gridCard: { width: '48%', backgroundColor: '#1e1e1e', padding: 20, borderRadius: 10, alignItems: 'center', marginBottom: 15, borderWidth: 1, borderColor: '#333' },
  gridIcon: { fontSize: 28, marginBottom: 10 },
  gridTitle: { color: '#fff', fontWeight: 'bold', textAlign: 'center', fontSize: 13 },
  subScreen: { flex: 1, padding: 20 },
  backLink: { color: '#0066cc', fontSize: 14, marginBottom: 10, fontWeight: 'bold' },
  chatBox: { backgroundColor: '#1e1e1e', padding: 12, borderRadius: 8, marginBottom: 10 },
  boldText: { color: '#fff', fontWeight: 'bold' },
  commentRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 6, borderBottomWidth: 1, borderColor: '#2a2a2a' },
  commentUser: { color: '#ffd700', fontWeight: 'bold', fontSize: 13 },
  commentText: { color: '#fff', fontWeight: 'normal' },
  threeDots: { color: '#ff4444', fontSize: 18, fontWeight: 'bold', paddingHorizontal: 10 },
  commentInputRow: { flexDirection: 'row', alignItems: 'center', marginTop: 10 },
  videoPlayerPlaceholder: { width: '100%', height: 180, backgroundColor: '#000', justifyContent: 'center', alignItems: 'center', borderRadius: 8, marginBottom: 15 },
  videoPlaceholderText: { color: '#888', fontWeight: 'bold' },
  listCard: { backgroundColor: '#1e1e1e', padding: 16, borderRadius: 8, marginBottom: 10, borderWidth: 1, borderColor: '#333' },
  listCardText: { color: '#fff', fontSize: 15, fontWeight: 'bold' },
  videoCard: { backgroundColor: '#1e1e1e', padding: 14, borderRadius: 8, marginBottom: 10 },
  videoTitle: { color: '#fff', fontWeight: '500' },
  paymentCard: { backgroundColor: '#1e1e1e', padding: 20, borderRadius: 10, alignItems: 'center', marginTop: 20 },
  paymentInfoText: { color: '#ccc', textAlign: 'center', marginBottom: 15, fontSize: 14 },
  holderPhoneDisplay: { color: '#ffd700', fontSize: 22, fontWeight: 'bold', marginBottom: 15 },
  swipeTrigger: { marginTop: 20, padding: 15, backgroundColor: '#1e1e1e', borderRadius: 8, alignItems: 'center', borderWidth: 1, borderColor: '#444' },
  swipeText: { color: '#ffd700', fontWeight: 'bold', fontSize: 13 },
  modalOverlay: { flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.7)' },
  modalContent: { backgroundColor: '#1e1e1e', padding: 20, borderTopLeftRadius: 20, borderTopRightRadius: 20, maxHeight: height * 0.6 },
  sectionCard: { backgroundColor: '#1e1e1e', padding: 15, borderRadius: 8, marginBottom: 15 },
  holderInfo: { color: '#aaa', marginBottom: 15 },
  rowItem: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 8, borderBottomWidth: 1, borderColor: '#2a2a2a' },
  facultyCard: { backgroundColor: '#2a2a2a', padding: 12, borderRadius: 8, marginBottom: 10 }
});
