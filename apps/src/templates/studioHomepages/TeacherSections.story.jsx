import React from 'react';
import {Provider} from 'react-redux';
import sinon from 'sinon';
import {createStoreWithReducers, registerReducers} from '@cdo/apps/redux';
import teacherSections, {
  serverSectionFromSection,
  setSections
} from '../teacherDashboard/teacherSectionsRedux';
import TeacherSections from './TeacherSections';

export default storybook => storybook
  .storiesOf('TeacherSections', module)
  .addStoryTable(storyTable);

const sections = [
  {
    id: 11,
    name: "Algebra Period 1",
    teacherName: "Ms. Frizzle",
    linkToProgress: "to Progress tab",
    assignedTitle: "CS in Algebra",
    linkToAssigned: "to Course",
    studentCount: 14,
    linkToStudents: "to Manage Students tab",
    code: "ABCDEF",
    pairingAllowed: true,
    stageExtras: false,
    providerManaged: false,
  },
  {
    id: 12,
    name: "Algebra Period 2",
    teacherName: "Ms. Frizzle",
    linkToProgress: "to Progress tab",
    assignedTitle: "CS in Algebra",
    linkToAssigned: "to Course",
    studentCount: 19,
    linkToStudents: "to Manage Students tab",
    code: "EEB206",
    pairingAllowed: true,
    stageExtras: false,
    providerManaged: false,
  },
  {
    id: 13,
    name: "Period 3",
    teacherName: "Ms. Frizzle",
    linkToProgress: "to Progress tab",
    assignedTitle: "Course 4",
    linkToAssigned: "to Course",
    studentCount: 22,
    linkToStudents: "to Manage Students tab",
    code: "HPRWHG",
    pairingAllowed: true,
    stageExtras: false,
    providerManaged: false,
  },
];
const serverSections = sections.map(serverSectionFromSection);

const storyTable = [
  {
    name: 'teacher at least one section',
    description: 'shows a table of sections on the teacher homepage',
    story: () => {
      withFakeServer({sections: serverSections});
      registerReducers({teacherSections});
      const store = createStoreWithReducers();
      store.dispatch(setSections(serverSections));
      return (
        <Provider store={store}>
          <TeacherSections isRtl={false}/>
        </Provider>
      );
    }
  },
  {
    name: 'teacher, no sections yet',
    description: 'shows a set up message if the teacher does not have any sections yet',
    story: () => {
      withFakeServer();
      registerReducers({teacherSections});
      const store = createStoreWithReducers();
      return (
        <Provider store={store}>
          <TeacherSections isRtl={false}/>
        </Provider>
      );
    }
  },
];

function withFakeServer({courses = [], sections = []} = {}) {
  const server = sinon.fakeServer.create({
    autoRespond: true,
  });
  const successResponse = (body) => [
    200,
    {"Content-Type": "application/json"},
    JSON.stringify(body)
  ];
  server.respondWith('GET', '/dashboardapi/courses', successResponse(courses));
  server.respondWith('GET', '/dashboardapi/sections', successResponse(sections));
  server.respondWith('GET', '/v2/sections/valid_scripts', successResponse([]));
}
